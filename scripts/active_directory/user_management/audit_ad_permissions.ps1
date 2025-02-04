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

param (
    [switch]$NoScylla
)

# PowerShell 3.0 compatible way of checking for admin, requires admin was introduced later
$currentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Error "You must run this script as an administrator."
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