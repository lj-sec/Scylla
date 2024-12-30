# Scylla
A collection of PowerShell scripts falling into six categories made easily accessible by its core script.

Disclaimer: This is in an extremely early stage in development; the author shall hold no responsibility for damages or unwanted changes to machines due to the usage of any scripts in this repository. All required PowerShell/.NET versions will be documented on a per-script basis (typically 5.1 and 4.8 respectively); no scripts guaranteed to be compatible with depricated versions unless stated otherwise.

## 1. System Configuration
This section will focus on scripts to customize Windows to the user's preference. May work to include modifying terminal behavior and look, startup programs, DNS setup, VPN setups, network discovery, telemetry, and other preconfigurations.

## 2. Firewall
The Firewall section will feature different methods of firewall interactions such as creating/deleting/modifying rules, backing up and restoring rules, and pre-configured setups for competitions like [CCDC](https://www.nationalccdc.org).

## 3. Active Directory (AD)
These scripts will automate common tasks within an AD environment, such as bulk user creation, deletion, and modification; auditing changes within the AD; management of Groups, Organizational Units, and organization-wide Group Policies; and ensuring security and health. 

## 4. Software & Updates
The Sofware & Updates section will focus on the installation of security auditing and productivity software, as well as managing Windows updates and some third-party software updates (e.g. Git, antiviruses, etc.). May also work to include WSUS.

## 5. General Security
General Security will focus on hardening the operating system primarily using Group Policies/registry edits and adhering to Microsoft security baselines among other standards.

## 6. Inventory
Inventory scripts will work to quickly audit the currently running processes/active services, installed software, hardware specifications, and operating system info. May work to include collection of inventory from remote systems/network scanning.

## Core
The initial script--it acts as a menu system for all other scripts, making them easily accessible and ensuring their execution times and changes are centrally logged.