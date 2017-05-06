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
$Script_Version = "1.3"
$Script_Date = "05-06-2017"
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
  Run script with powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1
  or Use bat file provided
  
  Then Use the Menu Provided and
  Select the desired Services Configuration
    1. Default 
    2. Safe (Recommended Option) 
    3. Tweaked (Not supported for laptop ATM)

.ADVANCED USAGE
 One of the following Methods...
  1. Edit values at bottom of the script then run script
  2. Edit bat file and ru
  3. Run the script with one of these arguments/switches (space between multiple)

-- Basic Switches --
 Switches       Description of Switch
  -atos          (Accepts ToS)
  -auto          (Runs the script to be Automated.. Closes on - User Input, Errors, or End of Script)
  
--Update Switches--
 Switches       Description of Switch
  -usc           (Checks for Update to Script file before running)
  -use           (Checks for Update to Service file before running)
  -sic           (Skips Internet Check)
  
--AT YOUR OWN RISK Switches--
 Switches       Description of Switch
  -sec           (Skips Edition Check)
  -sbc           (Skips Build Check)

-- Service Configuration Switches --
 Switches       Description of Switch 
  -default       (Runs the script with Services to Default Configuration)
  -Set 1          ^Same as Above
  -Set default    ^Same as Above
  -safe          (Runs the script with Services to Black Viper's Safe Configuration)
  -Set 2          ^Same as Above
  -Set safe       ^Same as Above
  -tweaked       (Runs the script with Services to Black Viper's Tweaked Configuration)
  -Set 3          ^Same as Above
  -Set tweaked    ^Same as Above
  
-- Misc Switches --
 Switches       Description of Switch
  -diag          (Shows diagnostic information)     

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

If($Release_Type -eq "Stable") { $ErrorActionPreference= 'silentlycontinue' }

$Global:PassedArg = $args
$Global:filebase = $PSScriptRoot

# Ask for elevated permissions if required
If(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PassedArg" -Verb RunAs
    Exit
}

$TempFolder = $env:Temp
$ForBuild = 15063
$ForVer = 1703

$Version_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/Version/Version.csv"
$Service_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/BlackViper.csv"

If([System.Environment]::Is64BitProcess) { $OSType = 64 }

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

##########
# Pre-Script -End
##########

##########
# Multi Use Functions -Start
##########

Function MenuBlankLine { DisplayOutMenu "|                                                   |" 14 0 1 }
Function MenuLine { DisplayOutMenu "|---------------------------------------------------|" 14 0 1 }
Function LeftLine { DisplayOutMenu "| " 14 0 0 }
Function RightLine { DisplayOutMenu " |" 14 0 1 }
Function Openwebsite ([String]$Url) { [System.Diagnostics.Process]::Start($Url) }
Function DownloadFile ([String]$Url, [String]$FilePath) { (New-Object System.Net.WebClient).DownloadFile($Url, $FilePath) }

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

Function  AutomatedExitCheck ([int]$ExitBit) {
    If ($Automated -ne 1) {
        Write-Host ""
        Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
    }
    If ($ExitBit -eq 1) { Exit }
}

Function Error_Top_Display {
    Clear-Host
    DiagnosticCheck 0
    MenuLine
    LeftLine ;DisplayOutMenu "                      Error                      " 13 0 0 ;RightLine
    MenuLine
    MenuBlankLine
}

Function Error_Bottom {
    MenuLine
    MenuBlankLine
    AutomatedExitCheck 1
}

Function DiagnosticCheck ([int]$Bypass) {
    If($Release_Type -ne "Stable" -or $Bypass -eq 1) {
        $WindowVersion = [Environment]::OSVersion.Version.Major
        $FullWinEdition = (Get-WmiObject Win32_OperatingSystem).Caption
        $WindowsEdition =  $FullWinEdition.Split(' ')[-1]
        $WindowsBuild = [Environment]::OSVersion.Version.build
        $winV = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).releaseId
        $PCType = (Get-WmiObject -Class Win32_ComputerSystem).PCSystemType
        
        DisplayOutMenu " Diagnostic Output" 15 0 1
        DisplayOutMenu " --------Start--------" 15 0 1
        DisplayOutMenu " Script Version = $Script_Version" 15 0 1
        DisplayOutMenu " Services Version = $ServiceVersion" 15 0 1
        DisplayOutMenu " Error Type = $ErrorDi" 13 0 1
        DisplayOutMenu " Window = $WindowVersion" 15 0 1
        DisplayOutMenu " Edition = $WindowsEdition" 15 0 1
        DisplayOutMenu " Build = $WindowsBuild" 15 0 1
        DisplayOutMenu " Version = $winV" 15 0 1
        DisplayOutMenu " PC Type = $PCType" 15 0 1
        DisplayOutMenu " ServiceConfig = $Black_Viper" 15 0 1
        DisplayOutMenu " ToS = $Accept_ToS" 15 0 1
        DisplayOutMenu " Automated = $Automated" 15 0 1
        DisplayOutMenu " Script_Ver_Check = $Script_Ver_Check" 15 0 1
        DisplayOutMenu " Service_Ver_Check = $Service_Ver_Check" 15 0 1
        DisplayOutMenu " Internet_Check = $Internet_Check" 15 0 1
        DisplayOutMenu " Show_Changed = $Show_Changed" 15 0 1
        DisplayOutMenu " Show_Already_Set = $Show_Already_Set" 15 0 1
        DisplayOutMenu " Show_Non_Installed = $Show_Non_Installed" 15 0 1
        DisplayOutMenu " Edition_Check = $Edition_Check" 15 0 1
        DisplayOutMenu " Build_Check = $Build_Check" 15 0 1
        DisplayOutMenu " Args = $PassedArg" 15 0 1
        DisplayOutMenu " ---------End---------" 15 0 1
        Write-Host ""
    }
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
            y {If($Black_Viper -eq 0) {Black_Viper_Input} Else {Black_Viper_Set $Black_Viper}; $Black_Viper_Input = "Out"}
            yes {If($Black_Viper -eq 0) {Black_Viper_Input} Else {Black_Viper_Set $Black_Viper}; $Black_Viper_Input = "Out"}
            default {$Invalid = 1}
        }
    }
    Return
}

##########
# TOS -End
##########

#Check if you want to download the missing Service setting file
Function LoadWebCSV {
    $LoadWebCSV = 'X'
    while($LoadWebCSV -ne "Out") {
        Error_Top_Display
        $ErrorDi = "Missing File BlackViper.csv -LoadCSV"
        LeftLine ;DisplayOutMenu " The File " 2 0 0 ;DisplayOutMenu "BlackViper.csv" 15 0 0 ;DisplayOutMenu " is missing.             " 2 0 0 ;RightLine
        MenuBlankLine
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
            y {DownloadFile $Service_Url $ServiceFilePath ;$LoadWebCSV = "Out"}
            yes {DownloadFile $Service_Url $ServiceFilePath ;$LoadWebCSV = "Out"}
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
        LeftLine ;DisplayOutMenu " Settings are ment for x64. Use AT YOUR OWN RISK." 13 0 0 ;RightLine
    }
    MenuBlankLine
    MenuLine
    MenuBlankLine
    For($i=2; $i -le 4; $i++) {
        If(!($i -eq 4 -and $IsLaptop -eq "-Lap")) { LeftLine ;DisplayOutMenu $ChToDisplay[$i] 14 0 0 ;RightLine } 
    }
    LeftLine ;DisplayOutMenu $ChToDisplay[5] 13 0 0 ;RightLine
    MenuBlankLine
    MenuLine
    LeftLine ;DisplayOutMenu $ChToDisplay[6] 15 0 0 ;RightLine
    LeftLine ;DisplayOutMenu $ChToDisplay[7] 15 0 0 ;RightLine
    LeftLine ;DisplayOutMenu $ChToDisplay[8] 15 0 0 ;RightLine
    MenuLine
    LeftLine ;DisplayOutMenu "Script Version: " 15 0 0 ;DisplayOutMenu ("$Script_Version ($Script_Date)"+(" "*(30-$Script_Version.length - $Script_Date.length))) 11 0 0 ;RightLine
    LeftLine ;DisplayOutMenu "Services File last updated on: " 15 0 0 ;DisplayOutMenu ("$ServiceDate" +(" "*(18-$ServiceDate.length))) 11 0 0 ;RightLine
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
        For($i=1; $i -lt $CopyrightItems.length; $i++) { LeftLine ;DisplayOutMenu $CopyrightItems[$i] 2 0 0 ;RightLine }
        MenuLine
        Write-Host ""
        $CopyrightDisplay = Read-Host "`nPress 'Enter' to continue"
        Switch($CopyrightDisplay) { default {$CopyrightDisplay = "Out"} }
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

$Script:Black_Viper = 0         #0-Menu, 1-Default, 2-Safe, 3-Tweaked
$Script:argsUsed = 0

Function ServiceSet ([String]$BVService) {
    Clear-Host
    $CurrServices = Get-Service
    Write-Host "Changing Service Please wait..." -ForegroundColor Red -BackgroundColor Black
    Write-Host "-------------------------------"
    Foreach($item in $csv) {
        $ServiceName = $($item.ServiceName)
        $ServiceTypeNum = $($item.$BVService)
        If($ServiceName -like "*_*"){ $ServiceName = $CurrServices -like (-join($ServiceName.replace('?',''),"*")) }
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
            If($Show_Changed -eq 1){ DisplayOut $DispTemp  11 0 }
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
    ArgCheck
    $WindowVersion = [Environment]::OSVersion.Version.Major
    If($WindowVersion -ne 10) {
        Error_Top_Display
        $ErrorDi = "Not Window 10"
        LeftLine ;DisplayOutMenu " Sorry, this Script supports Windows 10 ONLY.    " 2 0 0 ;RightLine
        MenuBlankLine
        LeftLine ;DisplayOutMenu " You are using Window " 2 0 0 ;DisplayOutMenu ("$WindowVersion"+(" "*(27-$WindowVersion.length))) 15 0 0 ;RightLine
        Error_Bottom
    }

    $ErrorDi = ""
    $EBCount = 0
    $FullWinEdition = (Get-WmiObject Win32_OperatingSystem).Caption
    $WinEdition =  $FullWinEdition.Split(' ')[-1]
    #Pro = Microsoft Windows 10 Pro
    #Home = Microsoft Windows 10 Home
    If($WinEdition -eq "Home") {
        $WinEdition = "-Home"
    } ElseIf($WinEdition -eq "Pro" -or $Edition_Check -eq 1) {
        $WinEdition = "-Pro"
    } Else {
        $ErrorDi = "Edition"
        $EditionCheck = "Fail"
        $EBCount++
    }

    $BuildVer = [Environment]::OSVersion.Version.build
    # 15063 = Creator's Update
    # 14393 = Anniversary Update
    # 10586 = First Major Update
    # 10240 = First Release
    
    $Win10Ver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).releaseId
    # 1703 = Creator's Update
    # 1607 = Anniversary Update
    # 1511 = First Major Update
    # 1507 = First Release
    
    If($BuildVer -lt $ForBuild -and $Build_Check -ne 1) {
        If($EditionCheck -eq "Fail") {
            $ErrorDi += " & Build"
        } Else {
            $ErrorDi = "Build"
        }
        $ErrorDi += " Check Failed"
        $BuildCheck = "Fail"
        $EBCount++
    }

    If($EBCount -ne 0) {
        Error_Top_Display
        LeftLine ;DisplayOutMenu " Script won't run due to the following problem(s)" 2 0 0 ;RightLine
        MenuBlankLine
        MenuLine
        If($EditionCheck -eq "Fail") {
            MenuBlankLine
            LeftLine ;DisplayOutMenu " $EBCount. Not a valid Windows Edition for this Script. " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " Windows 10 Home and Pro Only                    " 2 0 0 ;RightLine
            MenuBlankLine
            LeftLine ;DisplayOutMenu " You are using " 2 0 0;DisplayOutMenu ("$FullWinEdition" +(" "*(34-$FullWinEdition.length))) 15 0 0 ;RightLine
            MenuBlankLine
            LeftLine ;DisplayOutMenu " Windows 10 Home and Pro Only                    " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " To skip use one of the following methods        " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " 1. Change " 2 0 0 ;DisplayOutMenu "Edition_Check" 15 0 0 ;DisplayOutMenu " to " 2 0 0 ;DisplayOutMenu "= 1" 15 0 0 ; ;DisplayOutMenu " in script file   " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " 2. Run Script with " 2 0 0 ;DisplayOutMenu "-sec" 15 0 0 ;DisplayOutMenu " argument                " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " 3. Change " 2 0 0 ;DisplayOutMenu "Skip_Edition_Check" 15 0 0 ;DisplayOutMenu " to " 2 0 0 ;DisplayOutMenu "=yes" 15 0 0 ; ;DisplayOutMenu " in bat file" 2 0 0 ;RightLine
            MenuBlankLine
            MenuLine
        }
        If($BuildCheck -eq "Fail") {
            MenuBlankLine
            LeftLine ;DisplayOutMenu " $EBCount. Not a valid Build for this Script.           " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " Lowest Build Recommended is Creator's Update    " 2 0 0 ;RightLine
            MenuBlankLine
            LeftLine ;DisplayOutMenu " You are using Build " 2 0 0;DisplayOutMenu ("$BuildVer" +(" "*(24-$BuildVer.length))) 15 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " You are using Version " 2 0 0;DisplayOutMenu ("$Win10Ver" +(" "*(23-$BuildVer.length))) 15 0 0 ;RightLine
            MenuBlankLine
            LeftLine ;DisplayOutMenu " To skip use one of the following methods        " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " 1. Change " 2 0 0 ;DisplayOutMenu "Build_Check" 15 0 0 ;DisplayOutMenu " to " 2 0 0 ;DisplayOutMenu "= 1" 15 0 0 ; ;DisplayOutMenu " in script file     " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " 2. Run Script with " 2 0 0 ;DisplayOutMenu "-sbc" 15 0 0 ;DisplayOutMenu " argument                " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " 3. Change " 2 0 0 ;DisplayOutMenu "Skip_Build_Check" 15 0 0 ;DisplayOutMenu " to " 2 0 0 ;DisplayOutMenu "=yes" 15 0 0 ; ;DisplayOutMenu " in bat file  " 2 0 0 ;RightLine
            MenuBlankLine
            MenuLine
        }
        AutomatedExitCheck 1
    }
    VariousChecks
}
    
Function VariousChecks {
    $ServiceFilePath = $filebase + "\BlackViper.csv"
    If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
        LoadWebCSV
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
                [System.Collections.ArrayList]$Script:csv = Import-Csv $ServiceFilePath
            }
            $SV=[Int]$Script_Version
            If($Script_Ver_Check -eq 1 -and $WebScriptVer -gt $SV) {
                If($Release_Type -eq "Stable") {
                    $DFilename = "BlackViper-Win10-Ver." + $WebScriptVer + ".ps1"
                    $Script_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/BlackViper-Win10.ps1"
                } Else {
                    $DFilename = "BlackViper-Win10-Ver." + $WebScriptVer + "-Testing.ps1"
                    $Script_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/Testing/BlackViper-Win10.ps1"
                }
                $WebScriptFilePath = $filebase + "\" + $DFilename
                Clear-Host
                MenuLine
                LeftLine ;DisplayOutMenu "                  Update Found!                  " 13 0 0 ;RightLine
                MenuLine
                MenuBlankLine
                LeftLine ;DisplayOutMenu "Downloading version " 15 0 0 ;DisplayOutMenu ("$WebScriptVer"    +(" "*(29-$WebScriptVer.length))) 11 0 0 ;RightLine
                LeftLine ;DisplayOutMenu "Will run " 15 0 0 ;DisplayOutMenu ("$DFilename"    +(" "*(40-$DFilename.length))) 11 0 0 ;RightLine
                LeftLine ;DisplayOutMenu "after download is complete.                       " 2 0 0 ;RightLine
                MenuBlankLine
                MenuLine
                DownloadFile $Script_Url $WebScriptFilePath
                $UpArg = ""
                If($Accept_ToS -ne 0) { $UpArg = $UpArg + "-atos" }
                If($Automated -eq 1) { $UpArg = $UpArg + "-auto" }
                If($Service_Ver_Check -eq 1) { $UpArg = $UpArg + "-use" }                
                If($Internet_Check -eq 1) { $UpArg = $UpArg + "-sic" }
                If($Edition_Check -eq 1) { $UpArg = $UpArg + "-sec" }
                If($Build_Check -eq 1) { $UpArg = $UpArg + "-sbc" }
                If($Black_Viper -eq 1) { $UpArg = $UpArg + "-default" }
                If($Black_Viper -eq 2) { $UpArg = $UpArg + "-safe" }
                If($Black_Viper -eq 3) { $UpArg = $UpArg + "-tweaked" }
                Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$WebScriptFilePath`" $UpArg" -Verb RunAs
                Exit
            }
        } Else {
            Error_Top_Display
            $ErrorDi = "No Internet"
            LeftLine ;DisplayOutMenu " Update Failed Because no internet was detected. " 2 0 0 ;RightLine
            MenuBlankLine
            LeftLine ;DisplayOutMenu " Tested by pinging github.com                    " 2 0 0 ;RightLine
            MenuBlankLine
            LeftLine ;DisplayOutMenu " To skip use one of the following methods        " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " 1. Change " 2 0 0 ;DisplayOutMenu "Internet_Check" 15 0 0 ;DisplayOutMenu " to " 2 0 0 ;DisplayOutMenu "= 1" 15 0 0 ; ;DisplayOutMenu " in script file  " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " 2. Run Script with " 2 0 0 ;DisplayOutMenu "-sic" 15 0 0 ;DisplayOutMenu " argument                " 2 0 0 ;RightLine
            LeftLine ;DisplayOutMenu " 3. Change " 2 0 0 ;DisplayOutMenu "Internet_Check" 15 0 0 ;DisplayOutMenu " to " 2 0 0 ;DisplayOutMenu "=no" 15 0 0 ; ;DisplayOutMenu " in bat file     " 2 0 0 ;RightLine
            MenuBlankLine
            MenuLine
            If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
                MenuBlankLine
                LeftLine ;DisplayOutMenu "The File " 2 0 0 ;DisplayOutMenu "BlackViper.csv" 15 0 0 ;DisplayOutMenu " is missing and the script" 2 0 0 ;RightLine
                LeftLine ;DisplayOutMenu "can't run w/o it.      " 2 0 0 ;RightLine
                MenuBlankLine
                MenuLine
                AutomatedExitCheck 1
            } Else {
                AutomatedExitCheck 0
            }
        }
    }
    $ServiceVersion = ($csv[0]."Def-Home")
    $ServiceDate = ($csv[0]."Def-Pro")
    $csvtemp.RemoveAt(0)
    ScriptPreStart
}

Function ScriptPreStart {
    If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
        $ErrorDi = "Missing File BlackViper.csv -ScriptPreStart"
        Error_Top_Display
        LeftLine ;DisplayOutMenu "The File " 2 0 0 ;DisplayOutMenu "BlackViper.csv" 15 0 0 ;DisplayOutMenu " is missing and couldn't  " 2 0 0 ;RightLine
        LeftLine ;DisplayOutMenu "couldn't download for some reason.               " 2 0 0 ;RightLine
        Error_Bottom
    }
    If($argsUsed -eq 2) {
        If($Automated -eq 0 -or $Accept_ToS -eq 0) {
            TOS
        } Else {
            Black_Viper_Set $Black_Viper
        }
    } ElseIf($Accept_ToS -eq 1) {
        Black_Viper_Input
    } ElseIf($Automated -eq 0 -or $Accept_ToS -eq 0) {
        TOS
    } ElseIf($Automated -eq 1) {
        Black_Viper_Input
    } Else {
        $ErrorDi = "Unknown -ScriptPreStart"
        Error_Top_Display
        LeftLine ;DisplayOutMenu "Unknown Error, Please send the Diagnostics Output" 2 0 0 ;RightLine
        LeftLine ;DisplayOutMenu "to me, with Subject of 'Unknown Error', thanks.  " 2 0 0 ;RightLine
        LeftLine ;DisplayOutMenu " E-mail - Madbomb122@gmail.com                   " 2 0 0 ;RightLine
        LeftLine ;DisplayOutMenu "Subject - Unkown Error                           " 2 0 0 ;RightLine
        Error_Bottom
        DiagnosticCheck 1
        AutomatedExitCheck 1
    }
}

Function ArgCheck {
    $IsLaptop = LaptopCheck
    If ($PassedArg.length -gt 0) {
        For($i=0; $i -le $PassedArg.length; $i++) {
		$ArgVal = $PassedArg[$i]
            If($ArgVal.StartsWith("-")){
                $ArgVal = $PassedArg[$i].ToLower()
                <#If($ArgVal -eq "-set" -and $PassedArg[($i+1)] -In 1..3) {
                    $Script:Black_Viper = $PassedArg[($i+1)]
                    $Script:argsUsed = 2                
                }#>
                If($ArgVal -eq "-set") {
                    $PasVal = $PassedArg[($i+1)]
                    If($PasVal -eq 1 -or "default") {
                       $Script:Black_Viper = 1
                       $Script:argsUsed = 2
                    } ElseIf($ArgVal -eq "safe") {
                        $Script:Black_Viper = 2
                        $Script:argsUsed = 2
                    } ElseIf($PasVal -eq 3 -or "tweaked") {
                        If($IsLaptop -ne "-Lap") {
                            $Script:Black_Viper = 3
                            $Script:argsUsed = 2
                        } Else {
                            $Script:argsUsed = 3
                        }
                    }
                } ElseIf($ArgVal -eq "-default") {
                    $Script:Black_Viper = 1
                    $Script:argsUsed = 2
                } ElseIf($ArgVal -eq "-safe") {
                    $Script:Black_Viper = 2
                    $Script:argsUsed = 2
                } ElseIf($ArgVal -eq "-tweaked") {
                    If($IsLaptop -ne "-Lap") {
                        $Script:Black_Viper = 3
                        $Script:argsUsed = 2
                    } Else {
                        $Script:argsUsed = 3
                    }
                } ElseIf($ArgVal -eq "-sbc") {
                    $Script:Build_Check = 1
                } ElseIf($ArgVal -eq "-sec") {
                    $Script:Edition_Check = 1
                } ElseIf($ArgVal -eq "-sic") {
                    $Script:Internet_Check = 1
                } ElseIf($ArgVal -eq "-usc") {
                    $Script:Script_Ver_Check = 1
                } ElseIf($ArgVal -eq "-use") {
                    $Script:Service_Ver_Check = 1
                } ElseIf($ArgVal -eq "-atos") {
                    $Script:Accept_ToS = 1
                } ElseIf($ArgVal -eq "-auto") {
                    $Script:Automated = 1
                    $Script:Accept_ToS = 1
                } ElseIf($ArgVal -eq "-diag") {
                    $Script:Diagnostic = 1
                }
            }
        }
    }
    If($Diagnostic -eq 1) {
        DiagnosticCheck 1
        Write-Host ""
        Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
		Exit
    }
    If($argsUsed -eq 3 -and $Automated -eq 1) {
        Error_Top_Display
        $ErrorDi = "Automated with Tweaked + Laptop (Not supported ATM)"
        LeftLine ;DisplayOutMenu "Script is set to Automated and...                " 2 0 0 ;RightLine
        LeftLine ;DisplayOutMenu "Laptops can't use Twaked option ATM.             " 2 0 0 ;RightLine
        Error_Bottom
    }
}

#--------------------------------------------------------------------------
# Edit values (Option) to your preferance

#----Safe to change Variables----
# Function = Option             #Choices
$Script:Accept_ToS = 0          #0 = See ToS
                                #Anything else = Accept ToS

$Script:Automated = 0           #0 = Pause on - User input, On Errors, or End of Script
                                #1 = Close on - User input, On Errors, or End of Script
# Automated = 1, Implies that you accept the "ToS"
#--------------------------------

#--------Update Variables-------
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
