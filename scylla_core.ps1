#Requires -Version 3.0
<#
.SYNOPSIS
Requires PS 3.0, .NET 4.5.2, and Administrator rights.

.NOTES
Author: Logan Jackson
Date: 2024

.LINK
Website: https://lj-sec.github.io/
#>

# PowerShell 3.0 compatible way of checking for admin, requires admin was introduced later
$currentUser = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent())
if (!$currentUser.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Write-Warning "`nYou must run this script as an administrator."
    Exit 1
}

# Creating a log file to note changes made to the system
$scyllaDir = "$env:HOMEDRIVE\Scylla"
$scyllaLogsDir = "$scyllaDir\Logs"

mkdir -ErrorAction SilentlyContinue $scyllaDir | Out-Null
mkdir -ErrorAction SilentlyContinue $scyllaLogsDir | Out-Null
$curTime = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = "$scyllaLogsDir\log_$curTime.txt"
Write-Host "`nEstablishing a log file at $logFile"
Out-File $logFile

# Write-Log Function to write logs to $logFile
function Write-Log {
    param (
        [string]$message,
        [switch]$NoDate,
        [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
        [string]$Echo = $null
    )

    if($Echo)
    {
        Write-Host -ForegroundColor $Echo "$message"
    }

    if($NoDate.IsPresent)
    {
        Write-Output "// $message" | Out-File $logFile -Append
    }
    else
    {
        $currentTime = Get-Date -Format "MM/dd/yyyy HH:mm:ss K"
        Write-Output "$currentTime - $message" | Out-File $logFile -Append   
    }
}

# Repo root
$reporoot=$null
git help >$null
if($?)
{
    $reporoot = $(git rev-parse --show-toplevel 2>$null)
}
if(!$reporoot)
{
    Write-Log -Echo Red -NoDate "Repo root could not be established; core script depends on this to function"
}

Write-Log "Core script begins!"

Write-Host -ForegroundColor Red @"
      ████████████ ███████╗ ██████╗██╗   ██╗██╗     ██╗      █████╗ 
     █  █████████  ██╔════╝██╔════╝╚██╗ ██╔╝██║     ██║     ██╔══██╗
    ███  ███████   ███████╗██║      ╚████╔╝ ██║     ██║     ███████║
   █████  █████     ════██║██║       ╚██╔╝  ██║     ██║     ██╔══██║
 ████   ███  █     ███████║╚██████╗   ██║   ███████╗███████╗██║  ██║
█████████████      ╚══════╝ ╚═════╝   ╚═╝   ╚══════╝╚══════╝╚═╝  ╚═╝
"@

try
{
    $ErrorActionPreference = "Stop"
    Write-Host "---Main Menu---"
    $dirs = Get-ChildItem -Path $reporoot -Directory
    $dirs | ForEach-Object -Begin { $index = 1 } -Process {
        Write-Host "$($index): $($_.Name)"
        $index++
    }
}
catch
{
    Write-Log -Echo Red "Terminating error: $_"
}
finally
{
    Write-Log "Script ends!"
}