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
$Script_Version = "2.0"
$Script_Date = "05-21-2017"
#$Release_Type = "Stable"
$Release_Type = "Testing"
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
        2. Skip the check for 
            A. Home/Pro ($Script:Edition_Check variable bottom of script or use -sec switch) 
            B. Creator's Update ($Script:Build_Check variable bottom of script or use -sbc switch) 

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
  2. Edit bat file and run
  3. Run the script with one of these arguments/switches (space between multiple)

-- Basic Switches --
 Switches       Description of Switch
  -atos          (Accepts ToS)
  -auto          (Implies -Atos...Runs the script to be Automated.. Closes on - User Input, Errors, or End of Script)

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

-- Service Choice Switches --
  -all           (Every windows services will change)
  -min           (Just the services different from the default to safe/tweaked list)

--Update Switches--
 Switches       Description of Switch
  -usc           (Checks for Update to Script file before running)
  -use           (Checks for Update to Service file before running)
  -sic           (Skips Internet Check)
  
--AT YOUR OWN RISK Switches--
 Switches       Description of Switch
  -sec           (Skips Edition Check)
  -sbc           (Skips Build Check)

-- Misc Switches --
 Switches       Description of Switch
  -diag          (Shows diagnostic information, Dont use unless asked, Stops -auto)
  -log           (Makes a log file Script.log)
  -baf           (File of Services before and after the script)
--------------------------------------------------------------------------------#>

## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!!!!!                                                !!!!!!
## !!!!!!                    CAUTION                     !!!!!!
## !!!!!!          DO NOT EDIT PAST THIS POINT           !!!!!!
## !!!!!!                                                !!!!!!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

##########
# Pre-Script -Start
##########

If($Release_Type -eq "Stable") { $ErrorActionPreference = 'silentlycontinue' }

$Global:PassedArg = $args
$Global:filebase = $PSScriptRoot + "\"

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

Function MenuBlankLineLog { DisplayOutMenu "|                                                   |" 14 0 1 1 }
Function MenuLineLog { DisplayOutMenu "|---------------------------------------------------|" 14 0 1 1 }
Function LeftLineLog { DisplayOutMenu "| " 14 0 0 1 }
Function RightLineLog { DisplayOutMenu " |" 14 0 1 1 }

Function MenuBlankLine { DisplayOutMenu "|                                                   |" 14 0 1 0 }
Function MenuLine { DisplayOutMenu "|---------------------------------------------------|" 14 0 1 0 }
Function LeftLine { DisplayOutMenu "| " 14 0 0 0 }
Function RightLine { DisplayOutMenu " |" 14 0 1 0 }

Function Openwebsite ([String]$Url) { [System.Diagnostics.Process]::Start($Url) }
Function DownloadFile ([String]$Url, [String]$FilePath) { (New-Object System.Net.WebClient).DownloadFile($Url, $FilePath) }

Function DisplayOutMenu ([String]$TxtToDisplay,[int]$TxtColor,[int]$BGColor,[int]$NewLine,[int]$LogOut) {
    If($NewLine -eq 0) {
        If($MakeLog -eq 1 -and $LogOut -eq 1) { Write-Output $TxtToDisplay 4>&1 | Out-File -filepath $LogFile -NoNewline -Append }
        Write-Host -NoNewline $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
    } Else {
        If($MakeLog -eq 1 -and $LogOut -eq 1) { Write-Output $TxtToDisplay 4>&1 | Out-File -filepath $LogFile -Append }
        Write-Host $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
    }
}

Function DisplayOut ([String]$TxtToDisplay,[int]$TxtColor,[int]$BGColor) {
    If($MakeLog -eq 1) { Write-Output $TxtToDisplay 4>&1 | Out-File -filepath $LogFile -Append }
    If($TxtColor -le 15) {
        Write-Host $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
    } Else {
        Write-Host $TxtToDisplay
    }
}

Function  AutomatedExitCheck ([int]$ExitBit) {
    If ($Automated -ne 1) {
        Write-Host ""
        Read-Host -Prompt "Press Any key to Close..."
    }
    If ($ExitBit -eq 1) { Exit }
}

Function Error_Top_Display {
    Clear-Host
    DiagnosticCheck 0
    MenuLineLog
    LeftLineLog ;DisplayOutMenu "                      Error                      " 13 0 0 1 ;RightLineLog
    MenuLineLog
    MenuBlankLineLog
}

Function Error_Bottom {
    MenuLineLog
    MenuBlankLineLog
    If($Diagnostic -eq 1) {
        DiagnosticCheck 0
        Write-Host ""
        Read-Host -Prompt "Press Any key to Close..."
        Exit
    } Else {
        AutomatedExitCheck 1
    }
}

Function DiagnosticCheck ([int]$Bypass) {
    If($Release_Type -ne "Stable" -or $Bypass -eq 1 -or $Diagnostic -eq 1) {
        $WindowVersion = [Environment]::OSVersion.Version.Major
        $FullWinEdition = (Get-WmiObject Win32_OperatingSystem).Caption
        $WindowsBuild = [Environment]::OSVersion.Version.build
        $WinVer = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).releaseId
        $PCType = (Get-WmiObject -Class Win32_ComputerSystem).PCSystemType
        DisplayOutMenu " Diagnostic Output" 15 0 1 1
        DisplayOutMenu " Some items may be blank" 15 0 1 1
        DisplayOutMenu " --------Start--------" 15 0 1 1
        DisplayOutMenu " Script Version = $Script_Version" 15 0 1 1
        DisplayOutMenu " Services Version = $ServiceVersion" 15 0 1 1
        DisplayOutMenu " Error = $ErrorDi" 13 0 1 1
        DisplayOutMenu " Window = $WindowVersion" 15 0 1 1
        DisplayOutMenu " Edition = $FullWinEdition" 15 0 1 1
        DisplayOutMenu " Build = $WindowsBuild" 15 0 1 1
        DisplayOutMenu " Version = $WinVer" 15 0 1 1
        DisplayOutMenu " PC Type = $PCType" 15 0 1 1
        DisplayOutMenu " Desktop/Laptop = $IsLaptop" 15 0 1 1
        DisplayOutMenu " ServiceConfig = $Black_Viper" 15 0 1 1
        DisplayOutMenu " All/Min = $All_or_Min" 15 0 1 1        
        DisplayOutMenu " ToS = $Accept_ToS" 15 0 1 1
        DisplayOutMenu " Automated = $Automated" 15 0 1 1
        DisplayOutMenu " Script_Ver_Check = $Script_Ver_Check" 15 0 1 1
        DisplayOutMenu " Service_Ver_Check = $Service_Ver_Check" 15 0 1 1
        DisplayOutMenu " Internet_Check = $Internet_Check" 15 0 1 1
        DisplayOutMenu " Show_Changed = $Show_Changed" 15 0 1 1
        DisplayOutMenu " Show_Already_Set = $Show_Already_Set" 15 0 1 1
        DisplayOutMenu " Show_Non_Installed = $Show_Non_Installed" 15 0 1 1
        DisplayOutMenu " Edition_Check = $Edition_Check" 15 0 1 1
        DisplayOutMenu " Build_Check = $Build_Check" 15 0 1 1
        DisplayOutMenu " Args = $PassedArg" 15 0 1 1
        DisplayOutMenu " ---------End---------" 15 0 1 1
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

Function ShowInvalid ([Int]$InvalidA) {
    If($InvalidA -eq 1) {
        Write-Host ""
        Write-Host "Invalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline
        Return 0
    }
    Return 0
}

##########
# Multi Use Functions -End
##########

##########
# TOS -Start
##########

Function TOSDisplay {
    Clear-Host
    $BorderColor = 14
    If($Release_Type -ne "Stable") {
        $BorderColor = 15
        DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1 0
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "                  Caution!!!                     " 13 0 0 ;DisplayOutMenu " |" $BorderColor 0 1 0
        DisplayOutMenu "|                                                   |" $BorderColor 0 1 0
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu " This script is still being tested.              " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1 0
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "              USE AT YOUR OWN RISK.              " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1 0
        DisplayOutMenu "|                                                   |" $BorderColor 0 1 0
    }
    If($OSType -ne 64) {
        $BorderColor = 15
        DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1 0
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "                    WARNING!!                    " 13 0 0 ;DisplayOutMenu " |" $BorderColor 0 1 0
        DisplayOutMenu "|                                                   |" $BorderColor 0 1 0
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "      These settings are ment for x64 Bit.       " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1 0
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "              USE AT YOUR OWN RISK.              " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1 0
        DisplayOutMenu "|                                                   |" $BorderColor 0 1 0
    }
    DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1 0
    DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "                  Terms of Use                   " 11 0 0 ;DisplayOutMenu " |" $BorderColor 0 1 0
    DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1 0
    DisplayOutMenu "|                                                   |" $BorderColor 0 1 0
    DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "This program comes with ABSOLUTELY NO WARRANTY.  " 2 0 0 ;DisplayOutMenu " |" $BorderColor 0 1 0
    DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "This is free software, and you are welcome to    " 2 0 0 ;DisplayOutMenu " |" $BorderColor 0 1 0
    DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "redistribute it under certain conditions.        " 2 0 0 ;DisplayOutMenu " |" $BorderColor 0 1 0
    DisplayOutMenu "|                                                   |" $BorderColor 0 1 0
    DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "Read License file for full Terms.                " 2 0 0 ;DisplayOutMenu " |" $BorderColor 0 1 0
    DisplayOutMenu "|                                                   |" $BorderColor 0 1 0
    DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1 0
}

Function TOS {
    $TOS = 'X'
    while($TOS -ne "Out") {
        TOSDisplay
        $Invalid = ShowInvalid $Invalid
        $TOS = Read-Host "`nDo you Accept? (Y)es/(N)o"
        Switch($TOS.ToLower()) {
            n {Exit}
            no {Exit}
            y {If($Black_Viper -eq 0) {Black_Viper_Input} Else {Black_Viper_Set $Black_Viper $All_or_Min}; $Black_Viper_Input = "Out"}
            yes {If($Black_Viper -eq 0) {Black_Viper_Input} Else {Black_Viper_Set $Black_Viper $All_or_Min}; $Black_Viper_Input = "Out"}
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
        $Invalid = ShowInvalid $Invalid
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
    Clear-Host
    MenuLine
    LeftLine ;DisplayOutMenu $ChToDisplay[0] 11 0 0 0 ;RightLine
    MenuLine
    MenuBlankLine
    LeftLine ;DisplayOutMenu $ChToDisplay[1] 2 0 0 0 ;RightLine
    If($OSType -ne 64) {
        MenuBlankLine
        LeftLine ;DisplayOutMenu " Settings are ment for x64. Use AT YOUR OWN RISK." 13 0 0 0 ;RightLine
    }
    MenuBlankLine
    MenuLine
    LeftLine ;DisplayOutMenu $ChToDisplay[2] 14 0 0 ;DisplayOutMenu " | " 14 0 0 ;DisplayOutMenu $ChToDisplay[3] 14 0 0 ;RightLine
    LeftLine ;DisplayOutMenu $ChToDisplay[4] 14 0 0 ;DisplayOutMenu " | " 14 0 0 ;DisplayOutMenu $ChToDisplay[5] 14 0 0 ;RightLine
    For($i=6; $i -lt 14; $i++) {
        If(!($i -eq 4 -and $IsLaptop -eq "-Lap")) {LeftLine ;DisplayOutMenu $ChToDisplay[$i] 2 0 0 ;DisplayOutMenu " | " 14 0 0 ;DisplayOutMenu $ChToDisplay[$i+1] 2 0 0 ;RightLine }
        $i++
    }
    MenuLine
    LeftLine ;DisplayOutMenu $ChToDisplay[14] 13 0 0 0 ;RightLine
    MenuLine
    LeftLine ;DisplayOutMenu $ChToDisplay[15] 15 0 0 0 ;RightLine
    LeftLine ;DisplayOutMenu $ChToDisplay[16] 15 0 0 0 ;RightLine
    LeftLine ;DisplayOutMenu $ChToDisplay[17] 15 0 0 0 ;RightLine
    MenuLine
    LeftLine ;DisplayOutMenu "Script Version: " 15 0 0 0 ;DisplayOutMenu ("$Script_Version ($Script_Date)"+(" "*(30-$Script_Version.length - $Script_Date.length))) 11 0 0 0 ;RightLine
    LeftLine ;DisplayOutMenu "Services File last updated on: " 15 0 0 0 ;DisplayOutMenu ("$ServiceDate" +(" "*(18-$ServiceDate.length))) 11 0 0 0 ;RightLine
    MenuLine
}

Function Black_Viper_Input {
    $Black_Viper_Input = 'X'
    while($Black_Viper_Input -ne "Out") {
        MenuDisplay $BlackViperDisItems
        $Invalid = ShowInvalid $Invalid
        $Black_Viper_Input = Read-Host "`nChoice"
        switch -regex ($Black_Viper_Input) {
            "1A" {Black_Viper_Set 1 "-Full"; $Black_Viper_Input = "Out"}
            "2A" {Black_Viper_Set 2 "-Full"; $Black_Viper_Input = "Out"}
            "3A" {If($IsLaptop -ne "-Lap") {Black_Viper_Set 3 "-Full"; $Black_Viper_Input = "Out"} Else {$Invalid = 1}}
            "1M" {Black_Viper_Set 1 "-Min"; $Black_Viper_Input = "Out"}
            "2M" {Black_Viper_Set 2 "-Min"; $Black_Viper_Input = "Out"}
            "3M" {If($IsLaptop -ne "-Lap") {Black_Viper_Set 3 "-Min"; $Black_Viper_Input = "Out"} Else {$Invalid = 1}}
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
'                       ','                       ',
'   All Services        ','   Minimum Services    ',
' 1A. Default           ',' 1M. Default           ',
' 2A. Safe              ',' 2M. Safe              ',
' 3A. Tweaked           ',' 3M. Tweaked           ',
'                       ','                       ',
'Q. Quit (No changes)                             ',
'C. Display Copyright                             ',
"M. Go to Madbomb122's Github                     ",
"B. Go to Black Viper's Website                   ")

Function CopyrightDisplay {
    Clear-Host
    MenuLine
    LeftLine ;DisplayOutMenu $CopyrightItems[0] 11 0 0 0 ;RightLine
    MenuLine
    For($i=1; $i -lt $CopyrightItems.length-1; $i++) { LeftLine ;DisplayOutMenu $CopyrightItems[$i] 2 0 0 0 ;RightLine }
    MenuLine
    LeftLine ;DisplayOutMenu $CopyrightItems[$CopyrightItems.length-1] 13 0 0 0 ;RightLine
    MenuLine
    Write-Host ""
    Read-Host -Prompt "Press any key to Go back to Menu"
    Return
}

$CopyrightItems = @(
'                    Copyright                    ',
' Black Viper Services Configuration              ',
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
' SOFTWARE.                                       ',
"Press any key to go back to menu                 ")

$ServicesTypeList = @(
    '',          #0 -None (Not Installed, Default Only)
    'Disabled',  #1 -Disable
    'Manual',    #2 -Manual
    'Automatic', #3 -Automatic
    'Automatic'  #4 -Automatic (Delayed Start)
)

$Script:Black_Viper = 0
$Script:argsUsed = 0
$Script:All_or_Min = "-min"

Function ServiceBA ([String]$ServiceBA) {
    If($LogBeforeAfter -eq 1){
        $ServiceBAFile = $filebase + $ServiceBA
        Get-WmiObject -Class Win32_Service | select DisplayName, StartMode | Out-File $ServiceBAFile
    }
}

Function ServiceSet ([String]$BVService) {
    Clear-Host
    $CurrServices = Get-Service
    ServiceBA "Services-Before.log"
    DisplayOut "Changing Service Please wait..." 14 0
    DisplayOut "Service_Name - Current -> Change_To" 14 0
    DisplayOut "-------------------------------------" 14 0
    Foreach($item in $csv) {
        $ServiceTypeNum = $($item.$BVService)
        $ServiceName = $($item.ServiceName)
        If($ServiceTypeNum -eq 0 -and $Show_Skipped -eq 1) {
            $DispTemp = "Skipping $ServiceName"
            DisplayOut $DispTemp  14 0
        } ElseIf($ServiceTypeNum -ne 0) {
            If($ServiceName -like "*_*"){ $ServiceName = $CurrServices -like (-join($ServiceName.replace('?',''),"*")) }
            $ServiceType = $ServicesTypeList[$ServiceTypeNum]
            $ServiceCurrType = ServiceCheck $ServiceName $ServiceType
            if($ServiceName -is [system.array]){ $ServiceName = $ServiceName[0]}
            If($ServiceCurrType -ne $False -and $ServiceCurrType -ne "Already") {
                $DispTemp = "$ServiceName - $ServiceCurrType -> $ServiceType"
                If($ServiceTypeNum -In 1..3) {
                    Set-Service $ServiceName -StartupType $ServiceType
                } ElseIf($ServiceTypeNum -eq 4) {
                    $DispTemp = "$DispTemp (Delayed Start)"
                    Set-Service $ServiceName -StartupType $ServiceType
                    $RegPath = "HKLM:\System\CurrentControlSet\Services\"+($ServiceName)
                    Set-ItemProperty -Path $RegPath -Name "DelayedAutostart" -Type DWord -Value 1
                }
                If($Show_Changed -eq 1){ DisplayOut $DispTemp  11 0 }
            } ElseIf($ServiceCurrType -eq "Already" -and $Show_Already_Set -eq 1) {
                $DispTemp = "$ServiceName is already $ServiceType"
                DisplayOut $DispTemp  15 0
            } ElseIf($ServiceCurrType -eq $False -and $Show_Non_Installed -eq 1) {
                $DispTemp = "No service with name $ServiceName"
                DisplayOut $DispTemp  13 0
            }
        }
    }
    DisplayOut "-------------------------------------" 14 0
    DisplayOut "Service Changed..." 14 0
    ServiceBA "Services-After.log"
    AutomatedExitCheck 1
}

Function ServiceCheck ([string]$S_Name, [string]$S_Type) {
    If(Get-Service -Name "$S_Name"){
        $C_Type = (Get-Service $S_Name).StartType
        If($S_Type -ne $C_Type) {
            # Has to be removed or cant change service from disabled to anything else (Known Bug)
            If($S_Name -eq 'lfsvc' -and $C_Type -eq 'disabled') { Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3" -recurse -Force }
            If($S_Name -eq 'NetTcpPortSharing') { 
                If(Get-Service -Name "NetMsmqActivator" -and Get-Service -Name "NetPipeActivator" -and Get-Service -Name "NetTcpActivator"){ 
                    Return "Manual"
                } Else {
                    Return $False
                }
            }
            Return $C_Type
        } Else {
            Return "Already"
        }
    } Else {
        Return $False
    }
}

Function Black_Viper_Set ([Int]$BVOpt,[String]$FullMin) {
    If($BVOpt -eq 1) {
        ServiceSet ("Def"+$WinEdition+$FullMin)
    } ElseIf($BVOpt -eq 2) {
        ServiceSet ("Safe"+$IsLaptop+$FullMin)
    } ElseIf($BVOpt -eq 3) {
        ServiceSet ("Tweaked"+$IsLaptop+$FullMin)
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
        LeftLineLog ;DisplayOutMenu " Sorry, this Script supports Windows 10 ONLY.    " 2 0 0 1 ;RightLineLog
        MenuBlankLineLog
        LeftLineLog ;DisplayOutMenu " You are using Window " 2 0 0 1 ;DisplayOutMenu ("$WindowVersion"+(" "*(27-$WindowVersion.length))) 15 0 0 1 ;RightLineLog
        Error_Bottom
    }

    $ErrorDi = ""
    $EBCount = 0

    $FullWinEdition = (Get-WmiObject Win32_OperatingSystem).Caption
    $WinEdition = $FullWinEdition.Split(' ')[-1]
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
       $EBCount=0
        Error_Top_Display
        LeftLineLog ;DisplayOutMenu " Script won't run due to the following problem(s)" 2 0 0 1 ;RightLineLog
        MenuBlankLineLog
        MenuLineLog
        If($EditionCheck -eq "Fail") {
            $EBCount++
            MenuBlankLineLog
            LeftLineLog ;DisplayOutMenu " $EBCount. Not a valid Windows Edition for this Script. " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " Windows 10 Home and Pro Only                    " 2 0 0 1 ;RightLineLog
            MenuBlankLineLog
            LeftLineLog ;DisplayOutMenu " You are using " 2 0 0 1;DisplayOutMenu ("$FullWinEdition" +(" "*(34-$FullWinEdition.length))) 15 0 0 1 ;RightLineLog
            MenuBlankLineLog
            LeftLineLog ;DisplayOutMenu " Windows 10 Home and Pro Only                    " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " To skip use one of the following methods        " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " 1. Change " 2 0 0 1 ;DisplayOutMenu "Edition_Check" 15 0 0 1 ;DisplayOutMenu " to " 2 0 0 1 ;DisplayOutMenu "= 1" 15 0 0 1 ;DisplayOutMenu " in script file   " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " 2. Run Script with " 2 0 0 1 ;DisplayOutMenu "-sec" 15 0 0 1 ;DisplayOutMenu " argument                " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " 3. Change " 2 0 0 1 ;DisplayOutMenu "Skip_Edition_Check" 15 0 0 1 ;DisplayOutMenu " to " 2 0 0 1 ;DisplayOutMenu "=yes" 15 0 0 1 ;DisplayOutMenu " in bat file" 2 0 0 1 ;RightLineLog
            MenuBlankLineLog
            MenuLineLog
        }
        If($BuildCheck -eq "Fail") {
            $EBCount++
            MenuBlankLineLog
            LeftLineLog ;DisplayOutMenu " $EBCount. Not a valid Build for this Script.           " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " Lowest Build Recommended is Creator's Update    " 2 0 0 1 ;RightLineLog
            MenuBlankLineLog
            LeftLineLog ;DisplayOutMenu " You are using Build " 2 0 0 1 ;DisplayOutMenu ("$BuildVer" +(" "*(24-$BuildVer.length))) 15 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " You are using Version " 2 0 0 1 ;DisplayOutMenu ("$Win10Ver" +(" "*(23-$BuildVer.length))) 15 0 0 1 ;RightLineLog
            MenuBlankLineLog
            LeftLineLog ;DisplayOutMenu " To skip use one of the following methods        " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " 1. Change " 2 0 0 1 ;DisplayOutMenu "Build_Check" 15 0 0 1 ;DisplayOutMenu " to " 2 0 0 1 ;DisplayOutMenu "= 1" 15 0 0 1 ; ;DisplayOutMenu " in script file     " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " 2. Run Script with " 2 0 0 1 ;DisplayOutMenu "-sbc" 15 0 0 1 ;DisplayOutMenu " argument                " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " 3. Change " 2 0 0 1 ;DisplayOutMenu "Skip_Build_Check" 15 0 0 1 ;DisplayOutMenu " to " 2 0 0 1 ;DisplayOutMenu "=yes" 15 0 0 1 ; ;DisplayOutMenu " in bat file  " 2 0 0 1 ;RightLineLog
            MenuBlankLineLog
            MenuLineLog
        }
        AutomatedExitCheck 1
    }
    VariousChecks
}

Function VariousChecks {
    $ServiceFilePath = $filebase + "BlackViper.csv"
    If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
        If($Service_Ver_Check -eq 0) {
            If($MakeLog -eq 1) { Write-Output "Missing File 'BlackViper.csv'" | Out-File -filepath $LogFile }
            LoadWebCSV
        } Else {
            If($MakeLog -eq 1) { Write-Output "Downloading Missing File 'BlackViper.csv'" | Out-File -filepath $LogFile }
            DownloadFile $Service_Url $ServiceFilePath
            [System.Collections.ArrayList]$Script:csv = Import-Csv $ServiceFilePath
        }
        $Service_Ver_Check = 0
    }
    [System.Collections.ArrayList]$Script:csv = Import-Csv $ServiceFilePath
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
                If($MakeLog -eq 1) { Write-Output "Downloading update for 'BlackViper.csv'" | Out-File -filepath $LogFile }
                DownloadFile $Service_Url $ServiceFilePath
                [System.Collections.ArrayList]$Script:csv = Import-Csv $ServiceFilePath
            }
            $SV=[Int]$Script_Version
            If($Script_Ver_Check -eq 1 -and $WebScriptVer -gt $SV) {
                $DFilename = "BlackViper-Win10-Ver." + $WebScriptVer
                If($Release_Type -eq "Stable") {
                    $DFilename += ".ps1"
                    $Script_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/BlackViper-Win10.ps1"
                } Else {
                    $DFilename += "-Testing.ps1"
                    $Script_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/Testing/BlackViper-Win10.ps1"
                }
                $WebScriptFilePath = $filebase + $DFilename
                Clear-Host
                MenuLineLogLog
                LeftLineLog ;DisplayOutMenu "                  Update Found!                  " 13 0 0 1 ;RightLineLog
                MenuLineLog
                MenuBlankLineLog
                LeftLineLog ;DisplayOutMenu "Downloading version " 15 0 0 1 ;DisplayOutMenu ("$WebScriptVer"    +(" "*(29-$WebScriptVer.length))) 11 0 0 1 ;RightLineLog
                LeftLineLog ;DisplayOutMenu "Will run " 15 0 0 1 ;DisplayOutMenu ("$DFilename"    +(" "*(40-$DFilename.length))) 11 0 0 1 ;RightLineLog
                LeftLineLog ;DisplayOutMenu "after download is complete.                       " 2 0 0 1 ;RightLineLog
                MenuBlankLine
                MenuLineLog
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
                If($Diagnostic -eq 1) { $UpArg = $UpArg + "-diag" }
                If($LogBeforeAfter -eq 1) { $UpArg = $UpArg + "-baf" }
                If($MakeLog -eq 1) { $UpArg = $UpArg + "-logc $LogName" }
                If($All_or_Min -eq "-all") { 
                    $UpArg = $UpArg + "-full" 
                } Else {
                    $UpArg = $UpArg + "-min"
                }
                Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$WebScriptFilePath`" $UpArg" -Verb RunAs
                Exit
            }
        } Else {
            Error_Top_Display
            $ErrorDi = "No Internet"
            LeftLineLog ;DisplayOutMenu " Update Failed Because no internet was detected. " 2 0 0 1 ;RightLineLog
            MenuBlankLineLog
            LeftLineLog ;DisplayOutMenu " Tested by pinging github.com                    " 2 0 0 1 ;RightLineLog
            MenuBlankLineLog
            LeftLineLog ;DisplayOutMenu " To skip use one of the following methods        " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " 1. Change " 2 0 0 1 ;DisplayOutMenu "Internet_Check" 15 0 0 1 ;DisplayOutMenu " to " 2 0 0 1 ;DisplayOutMenu "= 1" 15 0 0 1 ; ;DisplayOutMenu " in script file  " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " 2. Run Script with " 2 0 0 1 ;DisplayOutMenu "-sic" 15 0 0 1 ;DisplayOutMenu " argument                " 2 0 0 1 ;RightLineLog
            LeftLineLog ;DisplayOutMenu " 3. Change " 2 0 0 1 ;DisplayOutMenu "Internet_Check" 15 0 0 1 ;DisplayOutMenu " to " 2 0 0 1 ;DisplayOutMenu "=no" 15 0 0 1 ; ;DisplayOutMenu " in bat file     " 2 0 0 1 ;RightLineLog
            MenuBlankLineLog
            MenuLineLog
            If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
                MenuBlankLineLog
                LeftLineLog ;DisplayOutMenu "The File " 2 0 0 1 ;DisplayOutMenu "BlackViper.csv" 15 0 0 1 ;DisplayOutMenu " is missing and the script" 2 0 0 1 ;RightLineLog
                LeftLineLog ;DisplayOutMenu "can't run w/o it.      " 2 0 0 1 ;RightLineLog
                MenuBlankLineLog
                MenuLineLog
                AutomatedExitCheck 1
            } Else {
                AutomatedExitCheck 0
            }
        }
    }
    $ServiceVersion = ($csv[0]."Def-Home-Full")
    $ServiceDate = ($csv[0]."Def-Home-Min")
    $csv.RemoveAt(0)
    ScriptPreStart
}

Function ScriptPreStart {
    If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
        $ErrorDi = "Missing File BlackViper.csv -ScriptPreStart"
        Error_Top_Display
        LeftLineLog ;DisplayOutMenu "The File " 2 0 0 1 ;DisplayOutMenu "BlackViper.csv" 15 0 0 1 ;DisplayOutMenu " is missing and couldn't  " 2 0 0 1 ;RightLineLog
        LeftLineLog ;DisplayOutMenu "couldn't download for some reason.               " 2 0 0 1 ;RightLineLog
        Error_Bottom
    }
    If($argsUsed -eq 2) {
        If($Automated -eq 0 -and $Accept_ToS -eq 0) {
            TOS
        } Else {
            Black_Viper_Set $Black_Viper $All_or_Min
        }
    } ElseIf($Accept_ToS -ne 0) {
        Black_Viper_Input
    } ElseIf($Automated -eq 0 -or $Accept_ToS -eq 0) {
        TOS
    } ElseIf($Automated -eq 1) {
        Black_Viper_Input
    } Else {
        $ErrorDi = "Unknown -ScriptPreStart"
        Error_Top_Display
        LeftLineLog ;DisplayOutMenu "Unknown Error, Please send the Diagnostics Output" 2 0 0 1 ;RightLineLog
        LeftLineLog ;DisplayOutMenu "to me, with Subject of 'Unknown Error', thanks.  " 2 0 0 1 ;RightLineLog
        LeftLineLog ;DisplayOutMenu " E-mail - Madbomb122@gmail.com                   " 2 0 0 1 ;RightLineLog
        LeftLineLog ;DisplayOutMenu "Subject - Unkown Error                           " 2 0 0 1 ;RightLineLog
        Error_Bottom
        DiagnosticCheck 1
        AutomatedExitCheck 1
    }
}

Function ArgCheck {
    $Script:IsLaptop = LaptopCheck
    If ($PassedArg.length -gt 0) {
        For($i=0; $i -lt $PassedArg.length; $i++) {
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
                    } ElseIf($PasVal -eq "safe") {
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
                } ElseIf($ArgVal -eq "-all") {
                    $Script:All_or_Min = "-full"
                } ElseIf($ArgVal -eq "-min") {
                    $Script:All_or_Min = "-min"
                } ElseIf($ArgVal -eq "-sec") {
                    $Script:Edition_Check = 1
                } ElseIf($ArgVal -eq "-sic") {
                    $Script:Internet_Check = 1
                } ElseIf($ArgVal -eq "-usc") {
                    $Script:Script_Ver_Check = 1
                } ElseIf($ArgVal -eq "-use") {
                    $Script:Service_Ver_Check = 1
                } ElseIf($ArgVal -eq "-atos") {
                    $Script:Accept_ToS = "Accepted-Switch"
                } ElseIf($ArgVal -eq "-auto") {
                    $Script:Automated = 1
                    $Script:Accept_ToS = "Accepted-Automated-Switch"
                } ElseIf($ArgVal -eq "-diag") {
                    $Script:Diagnostic = 1
                } ElseIf($ArgVal -eq "-log") {
                    $Script:MakeLog = 1
                    If(!($PassedArg[$i+1].StartsWith("-"))){ $Script:LogName = $PassedArg[$i+1] }
                } ElseIf($ArgVal -eq "-baf") {
                    $Script:LogBeforeAfter = 1
                } ElseIf($ArgVal -eq "-logc") {
                    $Script:MakeLog = 2
                    If(!($PassedArg[$i+1].StartsWith("-"))){ $Script:LogName = $PassedArg[$i+1] }
                }
            }
        }
    }
    If($argsUsed -eq 3 -and $Automated -eq 1) {
        Error_Top_Display
        $ErrorDi = "Automated with Tweaked + Laptop (Not supported ATM)"
        LeftLineLog ;DisplayOutMenu "Script is set to Automated and...                " 2 0 0 1 ;RightLineLog
        LeftLineLog ;DisplayOutMenu "Laptops can't use Twaked option ATM.             " 2 0 0 1 ;RightLineLog
        Error_Bottom
    }
    If($MakeLog -eq 1) {
        $Script:LogFile = $filebase + $LogName
        $Time = Get-Date -Format g
        Write-Output "--Start of Log ($Time)--" | Out-File -filepath $LogFile
    } ElseIf($MakeLog -eq 2) {
        Write-Output "Updated Script File running" 4>&1 | Out-File -filepath $LogFile -NoNewline -Append 
        $Script:LogFile = $filebase + $LogName
        $MakeLog = 1
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

$Script:MakeLog = 0             #0 = Dont make a log file
                                #1 = Make a log file
# Log file will be in same directory as script named `Script.log` (default)

$Script:LogName = "Script.log"  #Name of log file (you can change it)

$Script:LogBeforeAfter = 0      #0 = Dont make a file of all the services before and after the script
                                #1 = Make a file of all the services before and after the script
# File will be in same directory as script named `Services-Before.log` and `Services-After.log`
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
                                
$Script:Show_Skipped = 0        #0 = Dont Show Skipped Services
                                #1 = Show Skipped Services
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
