#Requires -Version 3.0
<#
.SYNOPSIS
Install .NET 4.8 Runtime if .NET is outdated
Requires PS 5.1, Administrator rights, and a Windows OS compatible with .NET 4.8 (Windows Server 2008 R2+)

.NOTES
Author: Logan Jackson
Date: 2024

.LINK
Website: https://lj-sec.github.io/
#>

param (
    [switch]$NoScylla
)

# PowerShell 3.0 compatible way of checking for admin, requires admin was introduced later
$currentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Warning "`nYou must run this script as an administrator."
    Exit 1
}

if ($NoScylla.IsPresent)
{
    function Write-Log
    {
        param (
            [Parameter(Mandatory)]
            [string]$Message,
            [string]$Echo = $null
        )
        if(!($null -eq $Echo))
        {
            Write-Host "$Message"
        }
    }
}
else
{
    if($MyInvocation.PSCommandPath -notlike "*scylla_core.ps1")
    {
        Write-Error "Script not launched from core Scylla script. Run with -NoScylla to avoid this check"
        Exit 1
    }
}

if(!$NoWarning.IsPresent)
{
    Write-Warning "This script will attempt to update the .NET version of this machine to 4.8"
    $warning = Read-Host "Are you sure you want to continue? (y/N)"
    if ($warning -inotlike "y*")
    {
        Exit 1
    }
}

$dotnet = Get-ItemProperty -ErrorAction SilentlyContinue 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full'

if (!$dotnet -or ($dotnet.Release -lt 528040))
{
    Write-Warning ".NET Framework is not 4.8 or above!"
    $updateNet = Read-Host "Would you like to update now? (Y/n)"

    if ($updateNet -ilike "n*")
    {
        Write-Host "Script exiting..."
        Exit 1
    }
    
    Write-Host "Updating .NET to 4.8..."

    try
    {
        Write-Host "Downloading .NET updater..."

        $installerPath = "$env:temp\net-updater.exe"

        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile("https://go.microsoft.com/fwlink/?LinkId=2085155", $installerPath)

        Write-Host "Running .NET updater..."
        Start-Process -FilePath $installerPath -ArgumentList "/quiet", "/norestart" -Wait

        Write-Host "Done!"
    }
    catch
    {
        Write-Error "Failed to update .NET Framework. Error: $_"
        Exit 2
    } 
    finally
    {
        if (Test-Path $installerPath)
        {
            Remove-Item $installerPath -Force
        }
    }

    if ($NoRestart -eq $false)
    {
        $confirmRestart = Read-Host "Restart now? (y/N)"
        if($confirmRestart -ilike "y*")
        {
            Write-Host "Restarting computer..."
            Start-Sleep 2
            Restart-Computer
        }
    }
}
else
{
    Write-Log -Echo Red ".NET is already 4.8+, version: $($dotnet.Version)"
}
Exit 0