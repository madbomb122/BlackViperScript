Param([alias("Set")] [string] $SettingImp)
##########
# Win10 Black Viper Service Configuration Script
#
# Black Viper's Service Configurations
#  Author: Charles "Black Viper" Sparks
# Website: http://www.blackviper.com/
#
# Script + Menu By
#  Author: Madbomb122
# Website: https://github.com/madbomb122/BlackViperScript/
#
$Script_Version = "1.1"
$Script_Date = "04-23-2017"
$Release_Type = "Stable"
##########

## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!!!!!                                                !!!!!!
## !!!!!!               SAFE TO EDIT ITEM                !!!!!!
## !!!!!!              AT BOTTOM OF SCRIPT               !!!!!!
## !!!!!!                                                !!!!!!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<#--------------------------------------------------------------------------------
    Copyright (c) 1999-2017 Charles "Black Viper" Sparks - Services Configuration

    The MIT License (MIT)

    Copyright (c) 2017 Madbomb122 - Black Viper Service Script

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
--------------------------------------------------------------------------------#>

<#--------------------------------------------------------------------------------
.Prerequisite to run script
    System: Windows 10 x64
    Edition: Home or Pro     (Can run on other Edition AT YOUR OWN RISK)
    Build: Creator's Update  (Can run on other Build AT YOUR OWN RISK)
    Files: This script and 'BlackViper.csv' (Service Configurations)

.DESCRIPTION
    Script that can set services based on Black Viper's Service Configurations. 

    AT YOUR OWN RISK YOU CAN 
        1. Run the script on x32 w/o changing settings (But shows a warning) 
        2. Change variable at bottom of script to skip the check for 
           A. Home/Pro ($Script:Edition_Check)
           B. Creator's Update ($Script:Build_Check)

.BASIC USAGE
    Use the Menu and select the desired Services Configuration

.ADVANCED USAGE
    Use one of the following Methods or use the at Bat file provided 
    (Bat file provided can run script, look in bat file for insructions)

1. Runs script with changing Services to Default Configuration (Only ones changed by this script): 
      -Set 1 
      -Set Default

Example: BlackViper-Win10.ps1 -Set 1
Example: BlackViper-Win10.ps1 -Set Default
------
2. Runs script with changing Services to Black Viper's Safe Configuration: 
      -Set 2 
      -Set Safe

Example: BlackViper-Win10.ps1 -Set 2
Example: BlackViper-Win10.ps1 -Set Safe
------
3. Runs script with changing Services to Black Viper's Tweaked Configuration: 
      -Set 3 
      -Set Tweaked

Example: BlackViper-Win10.ps1 -Set 3
Example: BlackViper-Win10.ps1 -Set Tweaked
--------------------------------------------------------------------------------#>

## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!!!!!                                                !!!!!!
## !!!!!!                    CAUTION                     !!!!!!
## !!!!!!          DO NOT EDIT PAST THIS POINT           !!!!!!
## !!!!!!                                                !!!!!!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#$Release_Type = "Testing"
#$Release_Type = "Stable"

##########
# Pre-Script -Start
##########

If($Release_Type -eq "Stable") {
    $ErrorActionPreference= 'silentlycontinue'
}

$Global:filebase = $PSScriptRoot

# Ask for elevated permissions if required
If(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $args" -Verb RunAs
    Exit
}

$TempFolder = $env:Temp
$ForBuild = 15063
$ForVer = 1703

$Version_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/Version/Version.csv"
$Service_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/BlackViper-Win10.ps1"
$Script_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/BlackViper-Win10.ps1"

If([System.Environment]::Is64BitProcess) {
    $OSType = 64
}

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

Function MenuBlankLine {
    DisplayOutMenu "|                                                   |" 14 0 1
}

Function MenuLine {
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
}

Function LeftLine {
    DisplayOutMenu "| " 14 0 0
}

Function RightLine {
    DisplayOutMenu " |" 14 0 1
}

##########
# Pre-Script -End
##########

##########
# Multi Use Functions -Start
##########

Function DisplayOutMenu ([String]$TxtToDisplay,[int]$TxtColor,[int]$BGColor,[int]$NewLine) {
    If($NewLine -eq 0) {
        Write-Host -NoNewline $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
    } Else {
        Write-Host $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
    }
}

Function DisplayOut ([String]$TxtToDisplay,[int]$TxtColor,[int]$BGColor) {
    If($TxtColor -le 15) {
        Write-Host $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
    } Else {
        Write-Host $TxtToDisplay
    }
}

Function Openwebsite ([String]$Url) {
    [System.Diagnostics.Process]::Start($Url)
}

Function  AutomatedExitCheck ([int]$ExitBit) {
    If ($Automated -ne 1) {
        Write-Host ""
        Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
    }
    If ($ExitBit -eq 1) {
        Exit
    }
}

Function DownloadFile ([String]$Url, [String]$FilePath) {
    (New-Object System.Net.WebClient).DownloadFile($Url, $FilePath)
}

Function Error_Top_Display {
    Clear-Host
    MenuLine
    LeftLine ;DisplayOutMenu "                      Error                      " 13 0 0 ;RightLine
    MenuLine
    MenuBlankLine
}

Function LaptopCheck {
    If((Get-WmiObject -Class Win32_ComputerSystem).PCSystemType -ne 2) {
         return "-Desk"
    } Else {
         return "-Lap"
    }
}

##########
# Multi Use Functions -End
##########

##########
# TOS -Start
##########

Function TOSDisplay {
    $BorderColor = 14
    If($Release_Type -ne "Stable") {
        $BorderColor = 15
        DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "                  Caution!!!                     " 13 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "|                                                   |" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu " This script is still being tested.              " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "              USE AT YOUR OWN RISK.              " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "|                                                   |" $BorderColor 0 1
    }
    If($OSType -ne 64) {
        $BorderColor = 15
        DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "                    WARNING!!                    " 13 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "|                                                   |" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "      These settings are ment for x64 Bit.       " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "              USE AT YOUR OWN RISK.              " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "|                                                   |" $BorderColor 0 1
    }
    DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1
    DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "                  Terms of Use                   " 11 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
    DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1
    DisplayOutMenu "|                                                   |" $BorderColor 0 1
    DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "This program comes with ABSOLUTELY NO WARRANTY.  " 2 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
    DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "This is free software, and you are welcome to    " 2 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
    DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "redistribute it under certain conditions.        " 2 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
    DisplayOutMenu "|                                                   |" $BorderColor 0 1
    DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "Read License file for full Terms.                " 2 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
    DisplayOutMenu "|                                                   |" $BorderColor 0 1
    DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1
}

Function TOS {
    $TOS = 'X'
    while($TOS -ne "Out") {
        Clear-Host
        TOSDisplay
        If($Invalid -eq 1) {
            Write-Host ""
            Write-Host "Invalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline
            $Invalid = 0
        }
        $TOS = Read-Host "`nDo you Accept? (Y)es/(N)o"
        Switch($TOS.ToLower()) {
            n {Exit}
            no {Exit}
            y {Black_Viper_Input}
            yes {Black_Viper_Input}
            default {$Invalid = 1}
        }
    }
    Return
}

##########
# TOS -End
##########

#Check if you want to download the missing Service setting file
Function LoadWebCSV ([String]$FilePath) {
    $LoadWebCSV = 'X'
    while($LoadWebCSV -ne "Out") {
        Error_Top_Display
        LeftLine ;DisplayOutMenu " Missing File 'BlackViper.csv'                   " 2 0 0 ;RightLine
        LeftLine ;DisplayOutMenu " Do you want to download the missing file?       " 2 0 0 ;RightLine
        MenuBlankLine
        MenuLine
        If($Invalid -eq 1) {
            Write-Host ""
            Write-Host "Invalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline
            $Invalid = 0
        }
        $LoadWebCSV = Read-Host "`nDownload? (Y)es/(N)o"
        Switch($LoadWebCSV.ToLower()) {
            n {Exit}
            no {Exit}
            y {DownloadServiceFile $FilePath;$LoadWebCSV = "Out"}
            yes {DownloadServiceFile $FilePath;$LoadWebCSV = "Out"}
            default {$Invalid = 1}
        }
    }
    Return
}

Function MenuDisplay ([Array]$ChToDisplay) {
    MenuLine
    LeftLine ;DisplayOutMenu $ChToDisplay[0] 11 0 0 ;RightLine
    MenuLine
    MenuBlankLine
    LeftLine ;DisplayOutMenu $ChToDisplay[1] 2 0 0 ;RightLine
    If($OSType -ne 64) {
        MenuBlankLine
        DisplayOutMenu "|" 14 0 0 ;DisplayOutMenu "  Settings are ment for x64. Use AT YOUR OWN RISK. " 13 0 0 ;DisplayOutMenu "|" 14 0 1
    }
    MenuBlankLine
    MenuLine
    MenuBlankLine
    For($i=2; $i -le 4; $i++) {
        If($i -eq 4 -and $IsLaptop -eq "-Lap") {
        } Else {
            LeftLine ;DisplayOutMenu $ChToDisplay[$i] 14 0 0 ;RightLine
        }
    }
    LeftLine ;DisplayOutMenu $ChToDisplay[5] 13 0 0 ;RightLine
    MenuBlankLine
    MenuLine
    LeftLine ;DisplayOutMenu $ChToDisplay[6] 15 0 0 ;RightLine
    LeftLine ;DisplayOutMenu $ChToDisplay[7] 15 0 0 ;RightLine
    LeftLine ;DisplayOutMenu $ChToDisplay[8] 15 0 0 ;RightLine
    MenuLine
    LeftLine ;DisplayOutMenu "Script Version: " 15 0 0 ; DisplayOutMenu "$Script_Version ($Script_Date)                 " 11 0 0 ; RightLine
    LeftLine ;DisplayOutMenu "Services File last updated on: " 15 0 0 ; DisplayOutMenu "$ServiceDate       " 11 0 0 ;RightLine
    MenuLine
}

Function Black_Viper_Input {
    $Black_Viper_Input = 'X'
    while($Black_Viper_Input -ne "Out") {
        Clear-Host
        MenuDisplay $BlackViperDisItems
        If($Invalid -eq 1) {
            Write-Host ""
            Write-Host "Invalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline
            $Invalid = 0
        }
        $Black_Viper_Input = Read-Host "`nChoice"
        switch($Black_Viper_Input.ToLower()) {
            1 {Black_Viper_Set 1; $Black_Viper_Input = "Out"}
            2 {Black_Viper_Set 2; $Black_Viper_Input = "Out"}
            3 {If($IsLaptop -ne "-Lap") {Black_Viper_Set 3; $Black_Viper_Input = "Out"} Else {$Invalid = 1}}
            C {CopyrightDisplay}
            M {Openwebsite "https://github.com/madbomb122/"}
            B {Openwebsite "http://www.blackviper.com/"}
            Q {Exit}
            default {$Invalid = 1}
        }
    }
}

$BlackViperDisItems = @(
"      Black Viper's Service Configurations       ",
"Settings based on Black Viper's Configurations.  ",
'1. Default                                       ',
'2. Safe                                          ',
'3. Tweaked                                       ',
'Q. Quit (No changes)                             ',
'C. Display Copyright                             ',
"M. Go to Madbomb122's Github                     ",
"B. Go to Black Viper's Website                   ")

Function CopyrightDisplay {
    $CopyrightDisplay = 'X'
    While($CopyrightDisplay -ne "Out") {
        Clear-Host
        MenuLine
        LeftLine ;DisplayOutMenu $CopyrightItems[0] 11 0 0 ;RightLine
        MenuLine
        For($i=1; $i -lt $CopyrightItems.length; $i++) {
            LeftLine ;DisplayOutMenu $CopyrightItems[$i] 2 0 0 ;RightLine
        }
        MenuLine
        Write-Host ""
        $CopyrightDisplay = Read-Host "`nPress 'Enter' to continue"
        Switch($CopyrightDisplay) {
            default {$CopyrightDisplay = "Out"}
        }
    }
    Return
}

$CopyrightItems = @(
'                    Copyright                    ',
' Services Configuration                          ',
' Copyright (c) 1999-2017                         ',
' Charles "Black Viper" Sparks                    ',
'                                                 ',
'              The MIT License (MIT)              ',
'                                                 ',
' Black Viper Service Script (This Script)        ',
' Copyright (c) 2017 Madbomb122                   ',
'                                                 ',
' Permission is hereby granted, free of charge, to',
' any person obtaining a copy of this software and',
' associated documentation files (the "Software"),',
' to deal in the Software without restriction,    ',
' including without limitation the rights to use, ',
' copy, modify, merge, publish, distribute,       ',
' sublicense, and/or sell copies of the Software, ',
' and to permit persons to whom the Software is   ',
' furnished to do so, subject to the following    ',
' conditions:                                     ',
'                                                 ',
' The above copyright notice and this permission  ',
' notice shall be included in all copies or       ',
' substantial portions of the Software.           ',
'                                                 ',
' THE SOFTWARE IS PROVIDED "AS IS", WITHOUT       ',
' WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,       ',
' INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF  ',
' MERCHANTABILITY, FITNESS FOR A PARTICULAR       ',
' PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL  ',
' THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR  ',
' ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER  ',
' IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,    ',
' ARISING FROM, OUT OF OR IN CONNECTION WITH THE  ',
' SOFTWARE OR THE USE OR OTHER DEALINGS IN THE    ',
' SOFTWARE.                                       ')

$ServicesTypeList = @(
    '',          #0 -None (Not Installed, Default Only)
    'Disabled',  #1 -Disable
    'Manual',    #2 -Manual
    'Automatic', #3 -Automatic
    'Automatic'  #4 -Automatic (Delayed Start)
)

$Script:Black_Viper = 0   #0-Skip, 1-Default, 2-Safe, 3-Tweaked

Function ServiceSet ([String]$BVService) {
    Clear-Host
    $CurrServices = Get-Service
    Write-Host "Changing Service Please wait..." -ForegroundColor Red -BackgroundColor Black
    Write-Host "-------------------------------"
    Foreach($item in $csv) {
        $ServiceName = $($item.ServiceName)
        $ServiceTypeNum = $($item.$BVService)
        If($ServiceName -like "*_*"){
            $ServiceName = $CurrServices -like (-join($ServiceName.replace('?',''),"*"))
        }
        $ServiceType = $ServicesTypeList[$ServiceTypeNum]
        $ServiceCurrType = (Get-Service $ServiceName).StartType
        $SrvCheck = ServiceCheck $ServiceName $ServiceType $ServiceCurrType
        If($SrvCheck -eq $True) {
             $DispTemp = "$ServiceName - $ServiceCurrType -> $ServiceType"
            If($ServiceTypeNum -In 1..3) {
                Set-Service $ServiceName -StartupType $ServiceType
            } ElseIf($ServiceTypeNum -eq 4) {
                $DispTemp = "$DispTemp (Delayed Start)"
                Set-Service $ServiceName -StartupType $ServiceType
                $RegPath = "HKLM\System\CurrentControlSet\Services\"+($ServiceName)
                Set-ItemProperty -Path $RegPath -Name "DelayedAutostart" -Type DWORD -Value 1
            }
            If($Show_Changed -eq 1){
                DisplayOut $DispTemp  11 0
            }
        } ElseIf($SrvCheck -eq $False -and $Show_Already_Set -eq 1) {
            $DispTemp = "$ServiceName is already $ServiceType"
            DisplayOut $DispTemp  15 0
        } ElseIf($Show_Non_Installed -eq 1) {
            $DispTemp = "No service with name $ServiceName"
            DisplayOut $DispTemp  13 0
        }
    }

    Write-Host "-------------------------------"
    Write-Host "Service Changed..."
    AutomatedExitCheck 1
}

Function ServiceCheck ([string]$S_Name, [string]$S_Type, [string]$C_Type) {
    If(Get-WmiObject -Class Win32_Service -Filter "Name='$S_Name'" ) {
        If($S_Type -ne $C_Type) {
            $ReturnV = $True
            If($S_Name -eq 'lfsvc' -and $C_Type -eq 'disabled') {
                # Has to be removed or cant change service from disabled to anything else (Known Bug)
                Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3" -recurse -Force
            }
        } Else {
            $ReturnV = $False
        }
    }
    Return $ReturnV
}

Function Black_Viper_Set ([Int]$Back_Viper) {
    If($Back_Viper -eq 1) {
        ServiceSet ("Def"+$WinEdition)
    } ElseIf($Back_Viper -eq 2) {
        ServiceSet ("Safe"+$IsLaptop)
    } ElseIf($Back_Viper -eq 3) {
        ServiceSet ("Tweaked"+$IsLaptop)
    }
}

Function InternetCheck {
    If($Internet_Check -eq 1) {
        Return $true
    } ElseIf(!(Test-Connection -computer github.com -count 1 -quiet)) {
        Return $false
    } Else {
        Return $true
    }
}

Function PreScriptCheck {
    $WindowVersion = [Environment]::OSVersion.Version.Major
    If($WindowVersion -ne 10) {
        Error_Top_Display
        LeftLine ;DisplayOutMenu " Sorry, this Script supports Windows 10 ONLY.    " 2 0 0 ;RightLine
        MenuBlankLine
        MenuLine
        AutomatedExitCheck 1
    }

    $WinEdition = (Get-WmiObject Win32_OperatingSystem).Caption
    #Pro = Microsoft Windows 10 Pro
    #Home = Microsoft Windows 10 Home
    If($WinEdition -eq "Microsoft Windows 10 Home") {
        $WinEdition = "-Home"
    } ElseIf($WinEdition -eq "Microsoft Windows 10 Pro" -or $Edition_Check -eq 1) {
        $WinEdition = "-Pro"
    } Else {
        $EditionCheck = "Failed"
        $DoNotRun = "Yes"
    }

    $BuildVer = [Environment]::OSVersion.Version.build
    # 15063 = Creator's Update
    # 14393 = Anniversary Update
    # 10586 = First Major Update
    # 10240 = First Release
    
    #$Win10Ver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).releaseId
    # 1703 = Creator's Update
    # 1607 = Anniversary Update
    # 1511 = First Major Update
    # 1507 = First Release
    
    If($BuildVer -lt $ForBuild -and $Build_Check -ne 1) {
        $BuildCheck = "Fail"
        $DoNotRun = "Yes"
    }

    If($DoNotRun -eq "Yes") {
        Error_Top_Display
        LeftLine ;DisplayOutMenu " Script won't run due to the following problem(s)" 2 0 0 ;RightLine
        MenuBlankLine
        If($EditionCheck -eq "Fail") {
            LeftLine ;DisplayOutMenu " Not a valid Windows Edition for this Script.    " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " Windows 10 Home and Pro Only                    " 2 0 0 ;RightLine
            MenuBlankLine
            LeftLine ;DisplayOutMenu " To skip change 'Edition_Check' in script file   " 11 0 0 ;RightLine
            MenuBlankLine
        }
        If($BuildCheck -eq "Fail") {
            LeftLine ;DisplayOutMenu " Not a valid Build for this Script.              " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " Lowest Build Recommended is Creator's Update    " 2 0 0 ;RightLine
            MenuBlankLine
            LeftLine ;DisplayOutMenu " To skip change 'Build_Check' in script file.    " 11 0 0 ;RightLine
            MenuBlankLine
        }
        MenuLine
        AutomatedExitCheck 1
    } Else {
        $ServiceFilePath = $filebase + "\BlackViper.csv"
        If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
            LoadWebCSV $ServiceFilePath
            $Service_Ver_Check = 0
        }
        $Script:csv = Import-Csv $ServiceFilePath
        If($Script_Ver_Check -eq 1 -or $Service_Ver_Check -eq 1) {
            If(InternetCheck) {
                $VersionFile = $TempFolder + "\Temp.csv"
                DownloadFile $Version_Url $VersionFile
                $CSV_Ver = Import-Csv $VersionFile
                If($Release_Type -eq "Stable") {
                    $WebScriptVer = $($CSV_Ver[0].Version)
                } Else {
                    $WebScriptVer = $($CSV_Ver[3].Version)
                }
                If($Service_Ver_Check -eq 1 -and $($CSV_Ver[1].Version) -gt $($csv[0]."Def-Home")) {
                    DownloadFile $Service_Url $ServiceFilePath
                }
                $SV=[Int]$Script_Version
                If($Script_Ver_Check -eq 1 -and $WebScriptVer -gt $SV) {
                    If($Release_Type -eq "Stable") {
                        $WebScriptFilePath = $filebase + "\BlackViper-Win10-Ver." + $WebScriptVer + ".ps1"
                    } Else {
                        $WebScriptFilePath = $filebase + "\BlackViper-Win10-Ver." + $WebScriptVer + "-Testing.ps1"
                    }
                    DownloadFile $Script_Url $WebScriptFilePath
                    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$WebScriptFilePath`" $args" -Verb RunAs
                    Exit
                }
            } Else {
                Error_Top_Display
                LeftLine ;DisplayOutMenu "No internet connection dectected.                " 2 0 0 ;RightLine
                LeftLine ;DisplayOutMenu "Tested by pinging github.com                     " 2 0 0 ;RightLine
                MenuBlankLine
                MenuLine
                If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
                    AutomatedExitCheck 1
                } Else {
                    AutomatedExitCheck 0
                }
            }
        }
        $ServiceDate = ($csv[0]."Def-Pro")
        $csv.RemoveRange(0,1)
    }
    $IsLaptop = LaptopCheck
    ScriptPreStart
}

Function ScriptPreStart {
    If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
        Error_Top_Display
        LeftLine ;DisplayOutMenu " The File 'BlackViper.csv' is missing and        " 2 0 0 ;RightLine
        LeftLine ;DisplayOutMenu " couldn't download for some reason.              " 2 0 0 ;RightLine
        MenuLine
        MenuBlankLine
        AutomatedExitCheck 1
    } 
    If($SettingImp -ne $null -and $SettingImp) {
        $Automated = 1
        If($SettingImp -In 1..2) {
            Black_Viper_Set $SettingImp
        } ElseIf($SettingImp -eq 3 -and $IsLaptop -ne "-Lap") {
            Black_Viper_Set $SettingImp
        } ElseIf($SettingImp.ToLower() -eq "default") {
            Black_Viper_Set 1
        } ElseIf($SettingImp.ToLower() -eq "safe") {
            Black_Viper_Set 2
        } ElseIf($SettingImp.ToLower() -eq "tweaked" -and $IsLaptop -ne "-Lap") {
            Black_Viper_Set 3
        } Else {
            Clear-Host
            MenuLine
            LeftLine ;DisplayOutMenu "             Error Invalid Selection             " 13 0 0 ;RightLine
            MenuLine
            MenuBlankLine
            LeftLine ;DisplayOutMenu " Valid Swiches are:                              " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " 1 or Default                                    " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " 2 or Safe                                       " 2 0 0 ;RightLine
            If($IsLaptop -eq "-Lap") {
                LeftLine ;DisplayOutMenu " 3 or Tweaked -Not Avilable for Laptop ATM       " 15 0 0 ;RightLine
            } Else {
                LeftLine ;DisplayOutMenu " 3 or Tweaked                                    " 2 0 0 ;RightLine
            }
            MenuBlankLine
            MenuLine
        }
    } ElseIf($Accept_TOS -eq 0) {
        TOS
    } Else {
        Black_Viper_Input
    }
}

#--------------------------------------------------------------------------

# Edit values (Option) to your preferance

#----Safe to change Variables----
# Function = Option             #Choices
$Script:Accept_TOS = 0          #0 = See TOS
                                #Anything else = Accept TOS

$Script:Automated = 0           #0 = Pause On Errors or End of Script
                                #1 = Close On Errors or End of Script

$Script:Script_Ver_Check = 0    #0 = Skip Check for update of Script File
                                #1 = Check for update of Script File
#Note: If found will Auto download and runs that
#File name will be "BlackViper-Win10-Ver.(version#).ps1"

$Script:Service_Ver_Check = 0   #0 = Skip Check for update of Service File
                                #1 = Check for update of Service File
#Note: If found will Auto download and uses that for the configuration
#--------------------------------

#--------Display Variables-------
# Function = Option             #Choices
$Script:Show_Changed = 1        #0 = Dont Show Changed Services
                                #1 = Show Changed Services

$Script:Show_Already_Set = 1    #0 = Dont Show Already set Services
                                #1 = Show Already set Services

$Script:Show_Non_Installed = 0  #0 = Dont Show Services not present
                                #1 = Show Services not present
#--------------------------------

#----CHANGE AT YOUR OWN RISK!----
# Function = Option             #Choices
$Script:Internet_Check = 0      #0 = Checks if you have internet by doing a ping to github.com
                                #1 = Bypass check if your pings are blocked

$Script:Edition_Check = 0       #0 = Check if Home or Pro Edition
                                #1 = Allows you to run on non Home/Pro

$Script:Build_Check = 0         #0 = Check Build (Creator's Update Minimum)
                                #1 = Allows you to run on Non-Creator's Update
#--------------------------------------------------------------------------

#Starts the script (Do not change)
PreScriptCheck
