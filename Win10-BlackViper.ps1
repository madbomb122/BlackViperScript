##########
# Win10 Black Viper Service Configuration Script
# 
# Black Viper's Service Configurations From
# Website: http://www.blackviper.com/service-configurations/black-vipers-windows-10-service-configurations/
#
# Script + Menu By
# Author: Madbomb122
# Website: https://github.com/madbomb122/
# Version: 0.3, 03-14-2017
#
# Release Type: Beta
##########

<#
    Copyright (c) 2017 Madbomb122 - Black Viper Service Script
    Copyright (c) 1999-2017 by Charles "Black Viper" Sparks - Actual settings for the Services
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#>

Param([alias("Set")] [string] $SettingImp)

$ErrorActionPreference= 'silentlycontinue'
$RelType = "Beta"
#$RelType = "Testing"
#$RelType = "Stable"

# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $args" -Verb RunAs
    Exit
}

Function TOSDisplay {
    Write-Host "                 Terms of Use                  " -ForegroundColor Green -BackgroundColor Black
    Write-Host "                                               " -ForegroundColor Black -BackgroundColor White
    Write-Host "This program comes with ABSOLUTELY NO WARRANTY." -ForegroundColor Black -BackgroundColor White
    Write-Host "This is free software, and you are welcome to  " -ForegroundColor Black -BackgroundColor White
    Write-Host "redistribute it under certain conditions.      " -ForegroundColor Black -BackgroundColor White
    Write-Host "                                               " -ForegroundColor Black -BackgroundColor White
    Write-Host "Read License file for full Terms.              " -ForegroundColor Black -BackgroundColor White
    Write-Host "                                               " -ForegroundColor Black -BackgroundColor White
    If ($OSType -ne 64){
        Write-Host "                                               " -ForegroundColor Red -BackgroundColor Black
        Write-Host "                 WARNING!!!                    " -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "     These settings are ment for x64 Bit.      " -ForegroundColor Red -BackgroundColor Black
        Write-Host "             Use AT YOUR OWN RISK.             " -ForegroundColor Red -BackgroundColor Black
        Write-Host "                                               " -ForegroundColor Red -BackgroundColor Black
    }
    If ($RelType -ne "Stable"){
        Write-Host "                                               " -ForegroundColor Red -BackgroundColor Black
        Write-Host "                 Caution!!!                    " -ForegroundColor Yellow -BackgroundColor Black
        Write-Host " Service Configuration are based on Creator's  " -ForegroundColor Red -BackgroundColor Black
        Write-Host " Update and is still being changed.            " -ForegroundColor Red -BackgroundColor Black
        Write-Host " Use AT YOUR OWN RISK.                         " -ForegroundColor Red -BackgroundColor Black
    }
}

function TOS {
    $TOS = 'X'
    while($TOS -ne "Out"){
        Clear-Host
        TOSDisplay
        If($Invalid -eq 1){
            Write-host ""
            Write-host "Invalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline
            $Invalid = 0
        }
        $TOS = Read-Host "`nAccept? (Y)es/(N)o"
        switch ($TOS.ToLower()) {
            n {Exit}
            no {Exit}
            y {Black_Viper_Input}
            yes {Black_Viper_Input}
            default {$Invalid = 1}
        }
    }
    Return
}

Function DisplayOutMenu([String]$TxtToDisplay,[int]$TxtColor,[int]$BGColor,[int]$NewLine){
    If ($NewLine -eq 0){
        Write-Host -NoNewline $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
    } Else {
        Write-Host $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
    }
}

function ChoicesDisplay ([Array]$ChToDisplay) {
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[0] 11 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|                                                   |" 14 0 1
    If ($OSType -ne 64){
        DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[2] 2 0 0 ;DisplayOutMenu "|" 14 0 1
        DisplayOutMenu "|                                                   |" 14 0 1
        DisplayOutMenu "|" 14 0 0 ;DisplayOutMenu "  Settings are ment for x64. Use AT YOUR OWN RISK. " 13 0 0 ;DisplayOutMenu "|" 14 0 1
    } Else {
        DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[1] 2 0 0 ;DisplayOutMenu "|" 14 0 1
        DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[2] 2 0 0 ;DisplayOutMenu "|" 14 0 1
	}
    DisplayOutMenu "|                                                   |" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|                                                   |" 14 0 1
    for ($i=3; $i -le 5; $i++) {
        DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[$i] 14 0 0 ;DisplayOutMenu "|" 14 0 1
    }
    DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[6] 13 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|                                                   |" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[7] 15 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[8] 15 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|" 14 0 0 ;DisplayOutMenu "          https://github.com/madbomb122/           " 15 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|" 14 0 0 ;DisplayOutMenu "            http://www.blackviper.com/             " 15 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
}

function OpenWebsite ([String]$Website){
    $IE=new-object -com internetexplorer.application
    $IE.navigate2($Website)
    $IE.visible=$true
}

function Black_Viper_Input {
    $Black_Viper_Input = 'X'
    while($Black_Viper_Input -ne "Out"){
        Clear-Host
        ChoicesDisplay $BlackViperDisItems
        If($Invalid -eq 1){
            Write-host ""
            Write-host "Invalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline
            $Invalid = 0
        }
        $Black_Viper_Input = Read-Host "`nChoice"
        switch ($Black_Viper_Input.ToLower()) {
            1 {Black_Viper_Set 1; $Black_Viper_Input = "Out"}
            2 {Black_Viper_Set 2; $Black_Viper_Input = "Out"}
            3 {Black_Viper_Set 3; $Black_Viper_Input = "Out"}
            M {OpenWebsite "https://github.com/madbomb122/Win10Script/"}
            B {OpenWebsite "http://www.blackviper.com/"}
            Q {Exit}
            default {$Invalid = 1}
        }
    }
}

If ([System.Environment]::Is64BitProcess) {
    $OSType = 64
}

$BlackViperDisItems = @(
"       Black Viper's Service Configurations      ",
"                                                 ",
"Settings based on Black Viper's Configurations.  ",
'1. Default                                       ',
'2. Safe                                          ',
'3. Tweaked                                       ',
'Q. Quit (No changes)                             ',
"M. Go to Madbomb122's Github                     ",
"B. Go to Black Viper's Website                   ")

$colors = @(
    "black",        #0
    "blue",         #1
    "cyan",         #2
    "darkblue",     #3
    "darkcyan",     #4
    "darkgray",     #5
    "darkgreen",    #6
    "darkmagenta",  #7
    "darkred",      #8
    "darkyellow",   #9
    "gray",         #10
    "green",        #11
    "magenta",      #12
    "red",          #13
    "white",        #14
    "yellow"        #15
)

$Script:Back_Viper = 0   #0-Skip, 1-Default, 2-Safe, 3-Tweaked
$Script:Automated = $false
# Back Viper's Website
# http://www.blackviper.com/service-configurations/black-vipers-windows-10-service-configurations/

$WinEdition = gwmi win32_operatingsystem | % caption
#Pro = Microsoft Windows 10 Pro
#Home = Microsoft Windows 10 Home 

$BuildVer = [environment]::OSVersion.Version.build
# 14393 = anniversary update
# 10586 = first major update
# 10240 = first release

$ServicesList = @(
# Layout of Array (Numbers in = Service Type)
#(Service Name, Def-Home, Def-Pro , Safe, Tweaked)
('AJRouter',2,2,2,1),                                #AllJoyn Router Service
('ALG',2,2,2,1),                                     #Application Layer Gateway Service
('BthHFSrv',2,2,2,1),                                #Bluetooth Handsfree Service
('bthserv',2,2,2,1),                                 #Bluetooth Support Service
('PeerDistSvc',0,2,1,1),                             #BranchCache
('CertPropSvc',2,2,2,1),                             #Certificate Propagation
('NfsClnt',0,0,1,1),                                 #Client for NFS
('CDPUserSvc_',3,3,2,2),                             #Connected Devices Platform User Service_
('PimIndexMaintenanceSvc_',2,2,1,1),                 #Contact Data_
('TrkWks',3,3,3,1),                                  #Distributed Link Tracking Client
('dmwappushsvc',2,2,1,1),                            #Diagnostics Tracking Service (DiagTrack) or dmwappushsvc
('MapsBroker',4,4,1,1),                              #Downloaded Maps Manager
('DusmSvc',3,3,3,1),                                 #DusmSvc
('Fax',2,2,1,1),                                     #Fax
('lfsvc',2,2,1,1),                                   #Geolocation Service
('hkmsvc',0,2,2,1),                                  #Health Key and Certificate Management Removed in Creators Update
('HvHost',2,2,1,1),                                  #HV Host Service
('vmickvpexchange',2,2,1,1),                         #Hyper-V Data Exchange Service
('vmicguestinterface',2,2,1,1),                      #Hyper-V Guest Service Interface
('vmicshutdown',2,2,1,1),                            #Hyper-V Guest Shutdown Service
('vmicheartbeat',2,2,1,1),                           #Hyper-V Heartbeat Service
('vmicvmsession',2,2,1,1),                           #Hyper-V PowerShell Direct Service
('vmicrdv',2,2,1,1),                                 #Hyper-V Remote Desktop Virtualization Service
('vmictimesync',2,2,1,1),                            #Hyper-V Time Synchronization Service
('vmicvss',2,2,1,1),                                 #Hyper-V Volume Shadow Copy Requestor
('irmon',2,2,1,1),                                   #Infrared monitor service
('SharedAccess',2,2,1,1),                            #Internet Connection Sharing (ICS)
('iphlpsvc',3,3,3,1),                                #IP Helper
('IpxlatCfgSvc',2,2,2,1),                            #IP Translation Configuration Service
('wlpasvc',2,2,2,1),                                 #LPA Service
('diagnosticshub.standardcollector.service',2,2,1,1),#Microsoft (R) Diagnostics Hub Standard Collector Service
('MSiSCSI',2,2,1,1),                                 #Microsoft iSCSI Initiator Service
('SmsRouter',2,2,1,1),                               #Microsoft Windows SMS Router Service
('NaturalAuthentication',2,2,2,1),                   #Natural Authentication
('NetTcpPortSharing',2,2,1,1),                       #Net.Tcp Port Sharing Service
('Netlogon',2,2,2,1),                                #Netlogon
('NcdAutoSetup',2,2,2,1),                            #Network Connected Devices Auto-Setup
('NcbService',2,2,2,1),                              #Network Connection Broker
('CscService',0,2,1,1),                              #Offline Files
('SEMgrSvc',2,2,1,1),                                #Payments and NFC/SE Manager
('PhoneSvc',2,2,1,1),                                #Phone Service
('RmSvc',2,2,1,1),                                   #Radio Management Service
('SessionEnv',2,2,2,1),                              #Remote Desktop Configuration
('TermService',2,2,2,1),                             #Remote Desktop Services
('UmRdpService',2,2,2,1),                            #Remote Desktop Services UserMode Port Redirector
('RpcLocator',2,2,1,1),                              #Remote Procedure Call (RPC) Locator
('RetailDemo',2,2,1,1),                              #Retail Demo Service
('SensorDataService',2,2,1,1),                       #Sensor Data Service
('SensrSvc',2,2,1,1),                                #Sensor Monitoring Service
('SensorService',2,2,1,1),                           #Sensor Service
('ScDeviceEnum',2,2,1,1),                            #Smart Card Device Enumeration Service
('SCPolicySvc',2,2,1,1),                             #Smart Card Removal Policy
('SNMPTRAP',2,2,1,1),                                #SNMP Trap
('StorSvc',2,2,2,1),                                 #Storage Service
('TabletInputService',2,2,1,1),                      #Touch Keyboard and Handwriting Panel Service
('WebClient',2,2,2,1),                               #WebClient
('WFDSConSvc',2,2,1,1),                              #WFDSConMgrSvc
('WbioSrvc',2,2,2,1),                                #Windows Biometric Service
('FrameServer',2,2,1,1),                             #Windows Camera Frame Server
('wcncsvc',2,2,2,1),                                 #Windows Connect Now - Config Registrar
('wisvc',2,2,1,1),                                   #Windows Insider Service
('WMPNetworkSvc',2,2,1,1),                           #Windows Media Player Network Sharing Service
('icssvc',2,2,1,1),                                  #Windows Mobile Hotspot Service
('Wms',0,3,1,1),                                     #Windows MultiPoint Server Host Service
('WmsRepair',0,3,1,1),                               #Windows MultiPoint Server Repair Service
('WinRM',2,2,1,1),                                   #Windows Remote Management (WS-Management)
('spectrum',2,2,2,1),                                #Windows Spectrum
('workfolderssvc',2,2,1,1),                          #Work Folders
('WwanSvc',2,2,1,1),                                 #WWAN AutoConfig
('XblAuthManager',2,2,1,1),                          #Xbox Live Auth Manager
('XblGameSave',2,2,1,1),                             #Xbox Live Game Save
('XboxNetApiSvc',2,2,1,1))                           #XboxNetApiSvc

$ServiceLen = $ServicesList.length

$ServicesTypeList = @(
    '',          #0 -None (Not Installed, Default Only)
    'disabled',  #1 -Disable
    'manual',    #2 -Manual
    'automatic', #3 -Auto Normal
    'automatic'  #4 -Auto Delay
)

Function ServiceSet([Int]$ServiceVal){
    Clear-Host
    Write-Host "Changing Service Please wait..."
    for ($i=0; $i -ne $ServiceLen; $i++) {
        $ServiceT = $ServicesList[$i][$ServiceVal]
        $ServiceName = $ServicesList[$i][0]
        $ServiceNameFull = GetServiceNameFull $ServiceName
        $ServiceType = $ServicesTypeList[$ServiceT]
        $ServiceCurrType = (Get-Service $ServiceNameFull).StartType
        If ((ServiceCheck $ServiceNameFull $ServiceType $ServiceCurrType) -eq $True){
            If($ServiceT -In 1..3){
                Write-Host $ServiceNameFull "-" $ServiceCurrType "->" $ServiceType
                Set-Service $ServiceNameFull -StartupType $ServiceType
            } ElseIf($ServiceT -eq 4){
                Write-Host $ServiceNameFull "-" $ServiceCurrType "->" $ServiceType" (Delayed Start)"
                Set-Service $ServiceNameFull -StartupType $ServiceType
                $RegPath = "HKLM\System\CurrentControlSet\Services\"+($ServiceNameFull)
                Set-ItemProperty -Path $RegPath -Name "DelayedAutostart" -Type DWORD -Value 1
            }
        } Else {
            Write-Host $ServiceNameFull "is already" $ServiceCurrType
        }
    }
    Write-Host "Service Changed..."
    If($Automated -ne $true){
        Write-Host "Press any key to close..."
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
    }
    Exit
}

Function GetServiceNameFull([String]$ServiceN){
    $ServiceR = $ServiceN
    If($ServiceN -eq 'CDPUserSvc_'){
        $ServiceR = Get-Service | Where-Object {$_.Name -like "CDPUserSvc_*"}
    } ElseIf($ServiceN -eq 'PimIndexMaintenanceSvc_'){
        $ServiceR = Get-Service | Where-Object {$_.Name -like "PimIndexMaintenanceSvc_*"}
    }
    Return $ServiceR
}

Function ServiceCheck([string] $S_Name, [string]$S_Type, [string]$C_Type) {
    [bool] $ReturnV = $False
    If (Get-WmiObject -Class Win32_Service -Filter "Name='$S_Name'" ) {
        If($S_Type -ne $C_Type){
            $ReturnV = $True
            If($S_Name -eq 'lfsvc'){
                #Has to be removed or cant change service 
                # from disabled to anything else (Known Bug)
                Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3"  -recurse  -Force
            }
        }
    }
    Return $ReturnV
}

function Black_Viper_Set ([Int]$Back_Viper){
    If ($Back_Viper -eq 1){
        If($WinEdition -eq "Microsoft Windows 10 Home"){
            ServiceSet $Back_Viper
        } ElseIf($WinEdition -eq "Microsoft Windows 10 Pro"){
            ServiceSet ($Back_Viper+1) 
        }
    } ElseIf ($Back_Viper -In 2..3){
        ServiceSet ($Back_Viper+1)
    }
}

If($WinEdition -eq "Microsoft Windows 10 Home" -or $WinEdition -eq "Microsoft Windows 10 Pro"){
    If ($SettingImp -ne $null -and $SettingImp){
        $Automated = $true
        If($SettingImp -In 1..3){
            Black_Viper_Set $SettingImp
        } ElseIf($SettingImp.ToLower() -eq "default"){
            Black_Viper_Set 1
        } ElseIf($SettingImp.ToLower() -eq "safe"){
            Black_Viper_Set 2
        } ElseIf($SettingImp.ToLower() -eq "tweaked"){
            Black_Viper_Set 3
        } Else{
            Write-Host "Invalid Selection" -ForegroundColor Blue -BackgroundColor Black
            Write-Host ""
            Write-Host "Valid Selections are:" -ForegroundColor Blue -BackgroundColor Black
            Write-Host "1 or Default" -ForegroundColor Green -BackgroundColor Black
            Write-Host "2 or Safe" -ForegroundColor Yellow -BackgroundColor Black
            Write-Host "3 or Tweaked" -ForegroundColor Red -BackgroundColor Black
            Write-Host ""
            Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
            $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
        }
    } Else{
        TOS
    }
} Else {
    Write-Host "Websites:"
    Write-Host "https://github.com/madbomb122/"
    Write-Host "http://www.blackviper.com/"
    Write-Host ""
    Write-Host "Not a Valid OS for this Script." -ForegroundColor Red -BackgroundColor Black
    Write-Host "Win 10 Home and Pro Only"
    Write-Host ""
    Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
}
