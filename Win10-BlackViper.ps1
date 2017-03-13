##########
# Win10 Black Viper Service Configurations
# 
# Black Viper's Settings from
# Website: http://www.blackviper.com/service-configurations/black-vipers-windows-10-service-configurations/
#
# Script + Menu By
# Author: Madbomb122
# Website: https://github.com/madbomb122/BlackViperScript/
# Version: 1.2, 03-04-2017
#
# Release Type: Stable
##########

<#
    Copyright (c) 2017 Madbomb122 - Black Viper's Service Configurations Script
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
    Write-Host "Do you Accept the Terms of Use? (Y)es/(N)o     " -ForegroundColor White -BackgroundColor Black    
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
    TitleBottom $ChToDisplay[0] 11
    DisplayOutMenu "|                                                   |" 14 0 1
    DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[1] 2 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[2] 2 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|                                                   |" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|                                                   |" 14 0 1
    for ($i=3; $i -le 5; $i++) {
        DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[$i] 2 0 0 ;DisplayOutMenu "|" 14 0 1
    }
    DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[6] 13 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|                                                   |" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[7] 15 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[8] 15 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|" 14 0 0 ;DisplayOutMenu "     https://github.com/madbomb122/Win10Script/    " 15 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|" 14 0 0 ;DisplayOutMenu "            http://www.blackviper.com/             " 15 0 0 ;DisplayOutMenu "|" 14 0 1    
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
}

function TitleBottom ([String]$TitleA,[Int]$TitleB) {
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    If($TitleB -eq 16) {
        DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu "Current Version: " 15 0 0 ;DisplayOutMenu $CurrVer 15 0 0 ;DisplayOutMenu " |" 14 0 0
        If($RelType -eq "Stable "){
            DisplayOutMenu " Release:" 11 0 0 ;DisplayOutMenu $RelType 11 0 0 ;
        } Else {
            DisplayOutMenu " Release:" 15 0 0 ;DisplayOutMenu $RelType 15 0 0 ;
        }
        DisplayOutMenu "|" 14 0 1
    } Else {
        DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $TitleA $TitleB 0 0 ;DisplayOutMenu "|" 14 0 1
    }
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

$BlackViperDisItems = @(
'       Black Viper Service Configurations        ',
' Will change the services based on your choice.  ',
" Settings based on Black Viper's Settings        ",
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

$ServicesList = @(
 #(Service Name, Def-Home, Def-Pro , Safe, Tweaked)
('AJRouter',2,2,2,1),
('ALG',2,2,2,1),
('BthHFSrv',2,2,2,1),
('bthserv',2,2,2,1),
('CDPUserSvc_',3,3,2,2),
('CertPropSvc',2,2,2,1),
('CscService',0,2,1,1),
('diagnosticshub.standardcollector.service',2,2,1,1),
('dmwappushsvc',2,2,1,1),
('DusmSvc',3,3,3,1),
#('EntAppSvc',2,2,1,1), -Cant change Setting
('Fax',2,2,1,1),
('FrameServer',2,2,1,1),
('hkmsvc',0,2,2,1),
('HvHost',2,2,1,1),
('icssvc',2,2,1,1),
('iphlpsvc',3,3,3,1),
('IpxlatCfgSvc',2,2,2,1),
('irmon',2,2,1,1),
('lfsvc',2,2,1,1),
('MapsBroker',4,4,1,1),
('MSiSCSI',2,2,1,1),
('NaturalAuthentication',2,2,2,1),
('NcbService',2,2,2,1),
('NcdAutoSetup',2,2,2,1),
('Netlogon',2,2,2,1),
('NetTcpPortSharing',2,2,1,1),
('PeerDistSvc',0,2,1,1),
('PhoneSvc',2,2,1,1),
('PimIndexMaintenanceSvc_',2,2,1,1),
('RetailDemo',2,2,1,1),
('RmSvc',2,2,1,1),
('RpcLocator',2,2,1,1),
('ScDeviceEnum',2,2,1,1),
('SCPolicySvc',2,2,1,1),
('SEMgrSvc',2,2,1,1),
('SensorDataService',2,2,1,1),
('SensorService',2,2,1,1),
('SensrSvc',2,2,1,1),
('SessionEnv',2,2,2,1),
('SharedAccess',2,2,1,1),
('SmsRouter',2,2,1,1),
('SNMPTRAP',2,2,1,1),
('spectrum',2,2,2,1),
('StorSvc',2,2,2,1),
('TabletInputService',2,2,1,1),
('TermService',2,2,2,1),
#('tiledatamodelsvc',3,3,3,1), -Cant change Setting
('TrkWks',3,3,3,1),
('UmRdpService',2,2,2,1),
('vmicguestinterface',2,2,1,1),
('vmicheartbeat',2,2,1,1),
('vmickvpexchange',2,2,1,1),
('vmicrdv',2,2,1,1),
('vmicshutdown',2,2,1,1),
('vmictimesync',2,2,1,1),
('vmicvmsession',2,2,1,1),
('vmicvss',2,2,1,1),
('WbioSrvc',2,2,2,1),
('wcncsvc',2,2,2,1),
('WebClient',2,2,2,1),
('WFDSConSvc',2,2,1,1),
('WinRM',2,2,1,1),
('wisvc',2,2,1,1),
('wlpasvc',2,2,2,1),
('WMPNetworkSvc',2,2,1,1),
('Wms',0,3,1,1),
('WmsRepair',0,3,1,1),
('workfolderssvc',2,2,1,1),
('WwanSvc',2,2,1,1),
('XblAuthManager',2,2,1,1),
('XblGameSave',2,2,1,1),
('XboxNetApiSvc',2,2,1,1))
$ServiceLen = $ServicesList.length

$ServicesTypeList = @(
    '',          #0 -None
    'disabled',  #1 -Disable
    'manual',    #2 -Manual
    'automatic', #3 -Auto Normal
    'automatic'  #4 -Atuo Delay
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
            Write-Host "Invalid Selection"  -ForegroundColor Blue -BackgroundColor Black
            Write-Host ""            
            Write-Host "Valid Selections are:"  -ForegroundColor Blue -BackgroundColor Black
            Write-Host "1 or Default"  -ForegroundColor Green -BackgroundColor Black
            Write-Host "2 or Safe"  -ForegroundColor Yellow -BackgroundColor Black
            Write-Host "3 or Tweaked"  -ForegroundColor Red -BackgroundColor Black
            Write-Host ""
            Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
            $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
        }
    } Else{
        TOS
    }
} Else {
    Write-Host "Websites:"
    Write-Host "https://github.com/madbomb122/Win10Script/"
    Write-Host "http://www.blackviper.com/"
    Write-Host ""
    Write-Host "Not a Valid OS for this Script."  -ForegroundColor Red -BackgroundColor Black
    Write-Host "Win 10 Home and Pro Only"
    Write-Host ""
    Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
}
