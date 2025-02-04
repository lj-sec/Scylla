#Requires -Version 3.0
<#
.SYNOPSIS
Requires PS 3.0 and Administrator rights

.NOTES
Author: Logan Jackson
Date: 2024

.LINK
Website: https://lj-sec.github.io/
#>

param(
    [switch]$NoScylla
)

# PowerShell 3.0 compatible way of checking for admin, requires admin was introduced later
$currentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Error "You must run this script as an administrator."
    Exit 1
}

if($NoScylla.IsPresent)
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
            Write-Host "`n$Message`n"
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

Write-Warning "This will attempt to install the Sysinternals Suite to $env:HOMEDRIVE\Sysinternals."
$warning = Read-Host "Are you sure you want to continue? (y/N)"
if ($warning -inotlike "y*")
{
    Break
}

Write-Host "Sysinternals"
if(Test-Path $env:HOMEDRIVE\Windows\SysInternalsSuite)
{
    $switchdirSysinternals = Read-Host "Sysinternals installed at $env:HOMEDRIVE\Windows\Sysinternals. Switch directories now? (y/N)"
    if($switchdirSysinternals -like "y*")
    {
        Set-Location "$env:HOMEDRIVE\Windows\Sysinternals"
        Break
    }
}
elseif(Test-Path $env:HOMEDRIVE\Windows\SysInternalsSuite.zip)
{
    $confirmSysUnzip = Read-Host "Unzip Sysinterals?"
    if($confirmSysUnzip -ilike "y*")
    {
        Expand-Archive -Path $env:HOMEDRIVE\Windows\SysInternalsSuite -DestinationPath $env:HOMEDRIVE\Windows\SysInternalsSuite -Force
    }
}
else
{
    $confirmSysinternals = Read-Host "Sysinternals Suite is not detected, install now?"
    if($confirmSysinternals -ilike "y*")
    {
        Write-Host "Installing sysinternals..."
        $webClient.DownloadFile("https://download.sysinternals.com/files/SysinternalsSuite.zip","$env:HOMEDRIVE\Windows\SysInternalsSuite.zip") | Wait-Event
    }
}