##########
# Win10 Black Viper Service Settings
# 
# Black Viper's Settings from
# Website: http://www.blackviper.com/service-configurations/black-vipers-windows-10-service-configurations/
#
# Script + Menu By
# Author: Madbomb122
# Website: https://github.com/madbomb122/Win10Script/
# Version: 1.0, 02-22-2017
#
# Release Type: Test
##########

$ErrorActionPreference= 'silentlycontinue'

# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
     Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $args" -Verb RunAs
     Exit
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
'               Black Viper Services              ',
' Will change the services based on your choice.  ',
" Settings based on Black Viper's Settings        ",
'1. Default                                       ',
'2. Safe                                          ',
'3. Tweaked                                       ',
'Q. Quit (No changes)                             ',
"M. Go to Madbomb122's Github                     ",
"B. Go to Black Viper's Website                   "
)

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
# Back Viper's Website
# http://www.blackviper.com/service-configurations/black-vipers-windows-10-service-configurations/


$WinEdition = gwmi win32_operatingsystem | % caption
#Pro = Microsoft Windows 10 Pro
#Home = Microsoft Windows 10 Home 

$ServicesList = @(
 #(Service Name, Def-Home, Def-Pro , Safe, Tweaked)
('AJRouter',2,2,2,1),
('ALG',2,2,2,1),
('AppMgmt',0,2,2,2),
('AppVClient',0,1,1,1),
('BthHFSrv',2,2,2,1),
('bthserv',2,2,2,1),
('CDPUserSvc_',3,3,2,2),
('CertPropSvc',2,2,2,1),
('CscService',0,2,1,1),
('diagnosticshub.standardcollector.service',2,2,1,1),
('dmwappushsvc',2,2,1,1),
('DusmSvc',3,3,3,1),
('EntAppSvc',2,2,1,1),
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
('Sense',0,2,2,2),
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
('tiledatamodelsvc',3,3,3,1),
('TrkWks',3,3,3,1),
('UevAgentService',0,1,1,1),
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
('XboxNetApiSvc',2,2,1,1)
)
$ServiceLen = $ServicesList.length

$ServicesType = @(
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
        $Type = $ServicesType[$ServiceT]
        If ((ServiceCheck $ServiceNameFull $Type) -eq $True){
            If($ServiceT -In 1..3){
                Write-Host $ServiceNameFull "-" $Type
                Set-Service $ServiceNameFull -StartupType $Type
            } ElseIf($ServiceT -eq 4){
                Write-Host $ServiceNameFull "-" $Type" (Delayed Start)"
                Set-Service $ServiceNameFull -StartupType $Type
                $RegPath = "HKLM\System\CurrentControlSet\Services\"+($ServiceNameFull)
                Set-ItemProperty -Path $RegPath -Name "DelayedAutostart" -Type DWORD -Value 1
            } Else {
                Write-Host $ServiceNameFull "-" $Type " -None" 
            }
        }
    }
    Write-Host "Service Changed..."
    Write-Host "Press any key to close..."
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
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

Function ServiceCheck([string] $S_Name, [string]$S_Type) {
    [bool] $ReturnV = $False
    If ( Get-WmiObject -Class Win32_Service -Filter "Name='$S_Name'" ) {
        $ServType = (Get-Service $S_Name).StartType
        If($S_Type -ne $ServType){
            $ReturnV = $True
            If($S_Name -eq 'lfsvc'){
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
    Black_Viper_Input    
} Else {
    Write-Host "Websites:"
    Write-Host "https://github.com/madbomb122/Win10Script/"
    Write-Host "http://www.blackviper.com/"
    Write-Host ""
    Write-Host "Not a Valid OS for this Script."  -ForegroundColor Red -BackgroundColor 
    Write-Host "Win 10 Home and Pro Only"
    Write-Host ""
    Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
}
