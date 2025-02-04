#Requires -Version 3.0
<#
.SYNOPSIS
Requires PS 3.0, Administrator rights, and .NET 4.5+ on one of the following OS:
    - Windows Server 2012 R2
    - Windows Server 2012
    - Windows 2008 R2 SP1
    - Windows 8.1
    - Windows 7 SP1

.NOTES
Author: Logan Jackson
Date: 2024

.LINK
Website: https://lj-sec.github.io/
#>

param (
    [switch]$NoRestart,
    [switch]$NoScylla
)

# PowerShell 3.0 compatible way of checking for admin, requires admin was introduced later
$currentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Error "`nYou must run this script as an administrator."
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
    if ($MyInvocation.PSCommandPath -notlike "*scylla_core.ps1")
    {
        Write-Error "Script not launched from core Scylla script. Run with -NoScylla to avoid this check"
        Exit 1
    }
}

if ($PSVersionTable.PSVersion.Major -lt 5 -and $PSVersionTable.PSVersion.Minor -lt 1)
{


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
    Write-Log -Echo Red "PowerShell is already 5.1+, version: $($PSVersionTable.PSVersion.ToString())"    
}