Param([alias("Set")] [string] $SettingImp)
##########
# Win10 Black Viper Service Configuration Script
#
# Black Viper's Service Configurations From
# Website: http://www.blackviper.com/service-configurations/black-vipers-windows-10-service-configurations/
#
# Script + Menu By
# Author: Madbomb122
# Website: https://github.com/madbomb122/
#
$Script_Version = 0.5 #(03-18-2017)
$Release_Type = "Beta"
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

#$Release_Type = "Beta"
#$Release_Type = "Testing"
#$Release_Type = "Stable"

#$filebase = (Get-Item -Path ".\" -Verbose).FullName
$Global:filebase = $PSScriptRoot
$ErrorActionPreference= 'silentlycontinue'

# Ask for elevated permissions if required
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $args" -Verb RunAs
    Exit
}

$TempFolder = $env:Temp

Function TOSDisplay {
    If ($Release_Type -ne "Stable") {
        Write-Host "                 Caution!!!                    " -ForegroundColor Yellow -BackgroundColor Black
        Write-Host " Service Configuration are based on Creator's  " -ForegroundColor Red -BackgroundColor Black
        Write-Host " Update and is still being changed.            " -ForegroundColor Red -BackgroundColor Black
        Write-Host " Use AT YOUR OWN RISK.                         " -ForegroundColor Red -BackgroundColor Black
        Write-Host "                                               " -ForegroundColor Red -BackgroundColor Black
    }
    If ($OSType -ne 64) {
        Write-Host "                 WARNING!!!                    " -ForegroundColor Yellow -BackgroundColor Black
        Write-Host "     These settings are ment for x64 Bit.      " -ForegroundColor Red -BackgroundColor Black
        Write-Host "             Use AT YOUR OWN RISK.             " -ForegroundColor Red -BackgroundColor Black
        Write-Host "                                               " -ForegroundColor Red -BackgroundColor Black
    }
    Write-Host "                                               " -ForegroundColor Black -BackgroundColor White
    Write-Host "                 Terms of Use                  " -ForegroundColor Green -BackgroundColor Black
    Write-Host "                                               " -ForegroundColor Black -BackgroundColor White
    Write-Host "This program comes with ABSOLUTELY NO WARRANTY." -ForegroundColor Black -BackgroundColor White
    Write-Host "This is free software, and you are welcome to  " -ForegroundColor Black -BackgroundColor White
    Write-Host "redistribute it under certain conditions.      " -ForegroundColor Black -BackgroundColor White
    Write-Host "                                               " -ForegroundColor Black -BackgroundColor White
    Write-Host "Read License file for full Terms.              " -ForegroundColor Black -BackgroundColor White
    Write-Host "                                               " -ForegroundColor Black -BackgroundColor White
}

Function TOS {
    $TOS = 'X'
    while($TOS -ne "Out") {
        Clear-Host
        TOSDisplay
        If ($Invalid -eq 1) {
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

Function LoadWebCSV {
    $LoadWebCSV = 'X'
    while($LoadWebCSV -ne "Out") {
        Clear-Host
        Write-Host "Missing File 'BlackViper.csv'" -ForegroundColor Red -BackgroundColor Black
        Write-host "Download File from Madbomb122's Github?" -ForegroundColor Green -BackgroundColor Black
        If ($Invalid -eq 1) {
            Write-host ""
            Write-host "Invalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline
            $Invalid = 0
        }
        $LoadWebCSV = Read-Host "`n(Y)es/(N)o"
        switch ($LoadWebCSV.ToLower()) {
            n {Exit}
            no {Exit}
            y {DownloadServiceFile;$LoadWebCSV = "Out"}
            yes {DownloadServiceFile;$LoadWebCSV = "Out"}
            default {$Invalid = 1}
        }
    }
    Return
}

Function DisplayOutMenu([String]$TxtToDisplay,[int]$TxtColor,[int]$BGColor,[int]$NewLine) {
    If ($NewLine -eq 0) {
        Write-Host -NoNewline $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
    } Else {
        Write-Host $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
    }
}

Function DisplayOut([String]$TxtToDisplay,[int]$TxtColor,[int]$BGColor) {
    If ($TxtColor -le 15) {
        Write-Host $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
    } Else {
        Write-Host $TxtToDisplay
    }
}

Function ChoicesDisplay ([Array]$ChToDisplay) {
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|  " 14 0 0 ;DisplayOutMenu $ChToDisplay[0] 11 0 0 ;DisplayOutMenu "|" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|                                                   |" 14 0 1
    If ($OSType -ne 64) {
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

Function OpenWebsite ([String]$Website) {
    $IE=new-object -com internetexplorer.application
    $IE.navigate2($Website)
    $IE.visible=$true
}

Function Black_Viper_Input {
    $Black_Viper_Input = 'X'
    while($Black_Viper_Input -ne "Out") {
        Clear-Host
        ChoicesDisplay $BlackViperDisItems
        If ($Invalid -eq 1) {
            Write-host ""
            Write-host "Invalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline
            $Invalid = 0
        }
        $Black_Viper_Input = Read-Host "`nChoice"
        switch ($Black_Viper_Input.ToLower()) {
            1 {Black_Viper_Set 1; $Black_Viper_Input = "Out"}
            2 {Black_Viper_Set 2; $Black_Viper_Input = "Out"}
            3 {Black_Viper_Set 3; $Black_Viper_Input = "Out"}
            M {OpenWebsite "https://github.com/madbomb122/"}
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

$Script:Black_Viper = 0   #0-Skip, 1-Default, 2-Safe, 3-Tweaked
$Script:Automated = $false

$ServicesTypeList = @(
    '',          #0 -None (Not Installed, Default Only)
    'disabled',  #1 -Disable
    'manual',    #2 -Manual
    'automatic', #3 -Automatic
    'automatic'  #4 -Automatic (Delayed Start)
)

$BlackViperList = @(
    '',
    'Def-Home',
    'Def-Pro',
    'Safe',
    'Tweaked'
)

Function ServiceSet ([Int]$ServiceVal) {
    Clear-Host
    $BVService = $BlackViperList[$ServiceVal]
    Write-Host "Changing Service Please wait..." -ForegroundColor Red -BackgroundColor Black
    Write-host "-------------------------------"
    Foreach ($item in $csv) {
        $ServiceName = $($item.ServiceName)
        $ServiceTypeNum = $($item.$BVService)

        $ServiceNameFull = GetServiceNameFull $ServiceName

        $ServiceType = $ServicesTypeList[$ServiceTypeNum]
        $ServiceCurrType = (Get-Service $ServiceNameFull).StartType
        $SrvCheck = ServiceCheck $ServiceNameFull $ServiceType $ServiceCurrType
        If ($SrvCheck -eq $True) {
             $DispTemp = "$ServiceNameFull - $ServiceCurrType -> $ServiceType"
            If ($ServiceT -In 1..3) {
                DisplayOut $DispTemp  11 0
                #Set-Service $ServiceNameFull -StartupType $ServiceType
            } ElseIf ($ServiceT -eq 4) {
                $DispTemp = "$DispTemp (Delayed Start)"
                DisplayOut $DispTemp  11 0
               # Set-Service $ServiceNameFull -StartupType $ServiceType
               # $RegPath = "HKLM\System\CurrentControlSet\Services\"+($ServiceNameFull)
               # Set-ItemProperty -Path $RegPath -Name "DelayedAutostart" -Type DWORD -Value 1
            }
        } ElseIf ($SrvCheck -eq $False) {
            $DispTemp = "$ServiceNameFull is already $ServiceType"
            DisplayOut $DispTemp  15 0
        } ElseIf ($Release_Type -ne "Stable") {
            $DispTemp = "No service with name $ServiceName"
            DisplayOut $DispTemp  15 0  
        }
    }
    Write-Host "Service Changed..."

    If ($Automated -ne 1) {
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
    If (Get-WmiObject -Class Win32_Service -Filter "Name='$S_Name'" ) {
        If ($S_Type -ne $C_Type) {
            $ReturnV = $True
            If ($S_Name -eq 'lfsvc' -and $C_Type -eq 'disabled') {
                # Has to be removed or cant change service from disabled to anything else (Known Bug)
                Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3"  -recurse  -Force
            }
        } Else {
            $ReturnV = $False
        }
    }
    Return $ReturnV
}

Function Black_Viper_Set ([Int]$Back_Viper) {
    If ($Back_Viper -eq 1) {
        If ($WinEdition -eq "Microsoft Windows 10 Home") {
            ServiceSet $Back_Viper
        } ElseIf ($WinEdition -eq "Microsoft Windows 10 Pro") {
            ServiceSet ($Back_Viper+1)
        }
    } ElseIf ($Back_Viper -In 2..3) {
        ServiceSet ($Back_Viper+1)
    }
}

Function DownloadServiceFile {
    $url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/BlackViper.csv"
    (New-Object System.Net.WebClient).DownloadFile($url, $ServiceFilePath)
}

Function DownloadScriptFile {
    $ScriptFilePath = $filebase + "\Win10-BlackViper.ps1"
    $url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/Win10-BlackViper.ps1"
    (New-Object System.Net.WebClient).DownloadFile($url, $ScriptFilePath)
}

Function ScriptPreStart {
    $ServiceFilePath = $filebase + "\BlackViper.csv"

    If (!(Test-Path $ServiceFilePath -PathType Leaf)) {
        LoadWebCSV
        $Service_Ver_Check = 0
    }
	
    $Script:csv = Import-Csv $ServiceFilePath
    
    If ($Script_Ver_Check -eq 1 -or $Service_Ver_Check -eq 1) {
        $VerFile = $TempFolder + "\Temp.csv"
        $SerVerURL = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/Version/Version.csv"
        (New-Object System.Net.WebClient).DownloadFile($SerVerURL, $VerFile)
        $CSV_Ver = Import-Csv $ServiceFilePath
        If ($Service_Ver_Check -eq 1 -and $CSV_Ver[1] -lt $csv[1]) {
		    DownloadServiceFile
        }
        If ($Script_Ver_Check -eq 1 -and $CSV_Ver[1] -lt $Script_Version) {
		    DownloadScriptFile
        }
    }

    $WinEdition = gwmi win32_operatingsystem | % caption
    #Pro = Microsoft Windows 10 Pro
    #Home = Microsoft Windows 10 Home

    If ($Skip_Edition_Check -eq 1 -and $WinEdition -ne "Microsoft Windows 10 Home") {
        $WinEdition = "Microsoft Windows 10 Pro"
    }

    $BuildVer = [environment]::OSVersion.Version.build
    # 14393 = Anniversary Update
    # 10586 = First Major Update
    # 10240 = First Release
    $ForBuild = 14393
    
<#
    If ($Skip_Build_Check -eq 1 -and $BuildVer -lt $ForBuild) {
        $BuildVer = $ForBuild
    }
    
    If ($BuildVer -ne 14393) {
        Write-Host "Not a Valid Build for this Script." -ForegroundColor Red -BackgroundColor Black
        Write-Host "Creator's Update Only"
        Write-Host ""
        Write-Host "To skip this change 'Skip_Build_Check' to 1 in script file"
        Write-Host ""
        $DoNotRun = "Yes"
    }
#>
    If (!($WinEdition -eq "Microsoft Windows 10 Home" -or $WinEdition -eq "Microsoft Windows 10 Pro")) {
        Write-Host "Not a Valid OS for this Script." -ForegroundColor Red -BackgroundColor Black
        Write-Host "Win 10 Home and Pro Only"
        Write-Host ""
        Write-Host "To skip this change 'Skip_Edition_Check' to 1 in script file"
        Write-Host ""
        $DoNotRun = "Yes"
    }
    If ($DoNotRun -eq "Yes") {
        Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
        Exit
    } Else{
        If ($SettingImp -ne $null -and $SettingImp) {
            $Automated = 1
            If ($SettingImp -In 1..3) {
                Black_Viper_Set $SettingImp
            } ElseIf ($SettingImp.ToLower() -eq "default") {
                Black_Viper_Set 1
            } ElseIf ($SettingImp.ToLower() -eq "safe") {
                Black_Viper_Set 2
            } ElseIf ($SettingImp.ToLower() -eq "tweaked") {
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
        } ElseIf ($Accept_TOS -eq 0) {
            TOS
        } Else {
            Black_Viper_Input
        }
    }
}

# --------------------------------------------------------------------------

#----Safe to change Variables----
$Script:Accept_TOS = 0          #0 = See TOS
                                #Anything else = Accept TOS

$Script:Automated = 0           #0 = Pause at end of Script
                                #1 = Close powershell at end of Script
							
$Script:Script_Ver_Check = 0    #0 = Skip Check for update of Script File
                                #1 = Check for update of Script File (Will AUTO download)

$Script:Service_Ver_Check = 0   #0 = Skip Check for update of Service File
                                #1 = Check for update of Service File (Will AUTO download)
#--------------------------------

#----CHANGE AT YOUR OWN RISK!----
$Script:Skip_Edition_Check = 0  #0 = Check if Home or Pro Edition
                                #1 = Allows you to run on non Home/Pro

$Script:Skip_Build_Check = 0    #0 = Check if Creator's Update
                                #1 = Allows you to run on non Home/Pro Creator's Update
#--------------------------------

# --------------------------------------------------------------------------

#Starts the script (Do not change)
ScriptPreStart
