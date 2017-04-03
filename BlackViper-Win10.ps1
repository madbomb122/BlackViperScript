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
$Script_Version = 0.9
$Script_Date = "04-02-2017"
$Release_Type = "Beta"
##########

<#
    Copyright (c) 2017 Madbomb122 - Black Viper Service Script
    Copyright (c) 1999-2017 Charles "Black Viper" Sparks - Services Configuration

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

$Global:filebase = $PSScriptRoot
$ErrorActionPreference= 'silentlycontinue'

# Ask for elevated permissions if required
If(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $args" -Verb RunAs
    Exit
}

$TempFolder = $env:Temp

$Version_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/Version/Version.csv"
$Service_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/BlackViper-Win10.ps1"
$Script_Url = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/BlackViper-Win10.ps1"

Function TOSDisplay {
    $BorderColor = 14
    If($Release_Type -eq "Testing" -or $Release_Type -eq "Beta") {
        $BorderColor = 15
        DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "                  Caution!!!                     " 13 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "|                                                   |" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu " Service Configuration are based on Creator's    " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu " Update and is still being changed.              " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu " Use AT YOUR OWN RISK.                           " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "|                                                   |" $BorderColor 0 1
    }
    If($OSType -ne 64) {
        $BorderColor = 15
        DisplayOutMenu "|---------------------------------------------------|" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "                    WARNING!!                    " 13 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "|                                                   |" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "      These settings are ment for x64 Bit.       " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
        DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "              Use AT YOUR OWN RISK.              " 14 0 0 ;DisplayOutMenu " |" $BorderColor 0 1
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

Function LoadWebCSV ([String]$FilePath) {
    $LoadWebCSV = 'X'
    while($LoadWebCSV -ne "Out") {
        Clear-Host
        DisplayOutMenu "|---------------------------------------------------|" 14 0 1
        DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu "                      Error                      " 13 0 0 ;DisplayOutMenu " |" 14 0 1
        DisplayOutMenu "|---------------------------------------------------|" 14 0 1
        DisplayOutMenu "|                                                   |" 14 0 1
        DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " Missing File 'BlackViper.csv'                   " 2 0 0 ;DisplayOutMenu " |" 14 0 1
        DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " Do you want to download the missing file?       " 2 0 0 ;DisplayOutMenu " |" 14 0 1
        DisplayOutMenu "|                                                   |" 14 0 1
        DisplayOutMenu "|---------------------------------------------------|" 14 0 1
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

Function ChoicesDisplay ([Array]$ChToDisplay) {
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu $ChToDisplay[0] 11 0 0 ;DisplayOutMenu " |" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|                                                   |" 14 0 1
    DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu $ChToDisplay[1] 2 0 0 ;DisplayOutMenu " |" 14 0 1
    If($OSType -ne 64) {
        DisplayOutMenu "|                                                   |" 14 0 1
        DisplayOutMenu "|" 14 0 0 ;DisplayOutMenu "  Settings are ment for x64. Use AT YOUR OWN RISK. " 13 0 0 ;DisplayOutMenu "|" 14 0 1
    }
    DisplayOutMenu "|                                                   |" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "|                                                   |" 14 0 1
    For($i=2; $i -le 4; $i++) {
        DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu $ChToDisplay[$i] 14 0 0 ;DisplayOutMenu " |" 14 0 1
    }
    DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu $ChToDisplay[5] 13 0 0 ;DisplayOutMenu " |" 14 0 1
    DisplayOutMenu "|                                                   |" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu $ChToDisplay[6] 15 0 0 ;DisplayOutMenu " |" 14 0 1
    DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu $ChToDisplay[7] 15 0 0 ;DisplayOutMenu " |" 14 0 1
    DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu $ChToDisplay[8] 15 0 0 ;DisplayOutMenu " |" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu "Script Version: " 15 0 0 ; DisplayOutMenu "$Script_Version ($Script_Date)                 " 11 0 0 ; DisplayOutMenu " |" 14 0 1
    DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu "Services File last updated on: " 15 0 0 ; DisplayOutMenu "$ServiceDate       " 11 0 0 ;DisplayOutMenu " |" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
}

Function Black_Viper_Input {
    $Black_Viper_Input = 'X'
    while($Black_Viper_Input -ne "Out") {
        Clear-Host
        ChoicesDisplay $BlackViperDisItems
        If($Invalid -eq 1) {
            Write-Host ""
            Write-Host "Invalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline
            $Invalid = 0
        }
        $Black_Viper_Input = Read-Host "`nChoice"
        switch($Black_Viper_Input.ToLower()) {
            1 {Black_Viper_Set 1; $Black_Viper_Input = "Out"}
            2 {Black_Viper_Set 2; $Black_Viper_Input = "Out"}
            3 {Black_Viper_Set 3; $Black_Viper_Input = "Out"}
            C {CopyrightDisplay}
            M {Openwebsite "https://github.com/madbomb122/"}
            B {Openwebsite "http://www.blackviper.com/"}
            Q {Exit}
            default {$Invalid = 1}
        }
    }
}

Function Openwebsite ([String]$Url) {
    [System.Diagnostics.Process]::Start($Url)
}

If([System.Environment]::Is64BitProcess) {
    $OSType = 64
}

# Displays items but NO Seperators
Function VariableDisplay ([Array]$VarToDisplay) {
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu $VarToDisplay[0] 11 0 0 ;DisplayOutMenu " |" 14 0 1
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    For($i=1; $i -lt $VarToDisplay.length; $i++) {
        DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu $VarToDisplay[$i] 2 0 0 ;DisplayOutMenu " |" 14 0 1
    }
    DisplayOutMenu "|---------------------------------------------------|" 14 0 1
    Write-Host ""
}

Function CopyrightDisplay {
    $CopyrightDisplay = 'X'
    While($CopyrightDisplay -ne "Out") {
        Clear-Host
        VariableDisplay $CopyrightItems
        $CopyrightDisplay = Read-Host "`nPress 'Enter' to continue"
        Switch($CopyrightDisplay) {
            default {$CopyrightDisplay = "Out"}
        }
    }
    Return
}

$CopyrightItems = @(
'                    Copyright                    ',
'                                                 ',
' Services Configuration                          ',
' Copyright (c) 1999-2017                         ', 
' Charles "Black Viper" Sparks                    ',
'                                                 ',
' This Script                                     ',
' Copyright (c) 2017 Madbomb122                   ',
'                                                 ',
' This program is free software: you can          ',
' redistribute it and/or modify This program is   ',
' free software This program is free software:    ',
' you can redistribute it and/or modify it under  ',
' the terms of the GNU General Public License as  ',
' published by the Free Software Foundation,      ',
' version 3 of the License.                       ',
'                                                 ',
' This program is distributed in the hope that it ',
' will be useful, but WITHOUT ANY WARRANTY;       ',
' without even the implied warranty of            ',
' MERCHANTABILITY or FITNESS FOR A PARTICULAR     ',
' PURPOSE.  See the GNU General Public License    ',
' for more details.                               ',
'                                                 ',
' You should have received a copy of the GNU      ',
' General Public License along with this program. ',
' If not, see <http://www.gnu.org/licenses/>.     ',
'                                                 ')

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
    'Disabled',  #1 -Disable
    'Manual',    #2 -Manual
    'Automatic', #3 -Automatic
    'Automatic'  #4 -Automatic (Delayed Start)
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

    If($Automated -ne 1) {
        Write-Host "-------------------------------"
        Write-Host "Service Changed..."
        Write-Host "Press any key to close..."
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
    }
    Exit
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
        If($WinEdition -eq "Microsoft Windows 10 Home") {
            ServiceSet $Back_Viper
        } ElseIf($WinEdition -eq "Microsoft Windows 10 Pro") {
            ServiceSet ($Back_Viper+1)
        }
    } ElseIf($Back_Viper -In 2..3) {
        ServiceSet ($Back_Viper+1)
    }
}

Function DownloadFile ([String]$Url, [String]$FilePath) {
    (New-Object System.Net.WebClient).DownloadFile($Url, $FilePath)
}

Function InternetCheck {
    If($Internet_Check -eq 1) {
        Return $true
	} ElseIf(!(Test-Connection -computer google.com -count 1 -quiet)) {
        If(!(Test-Connection -computer yahoo.com -count 1 -quiet)) {
            Return $false
        } Else {
            Return $true
        }
    } Else {
        Return $true
    }
}

Function PreScriptCheck {
    $WindowVersion = [Environment]::OSVersion.Version.Major
    
    If($WindowVersion -ne 10 -and $Automated -eq 0) {
        DisplayOutMenu "|---------------------------------------------------|" 14 0 1
        DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu "                      Error                      " 13 0 0 ;DisplayOutMenu " |" 14 0 1
        DisplayOutMenu "|---------------------------------------------------|" 14 0 1
        DisplayOutMenu "|                                                   |" 14 0 1
        DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " Sorry, this Script supports Windows 10 ONLY.    " 2 0 0 ;DisplayOutMenu " |" 14 0 1
        DisplayOutMenu "|                                                   |" 14 0 1
        DisplayOutMenu "|---------------------------------------------------|" 14 0 1
        Write-Host ""
        Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
        Exit
    }
    
    $WinEdition = gwmi win32_operatingsystem | % caption
    #Pro = Microsoft Windows 10 Pro
    #Home = Microsoft Windows 10 Home

    $BuildVer = [environment]::OSVersion.Version.build
    # 150?? = Creator's Update
    # 14393 = Anniversary Update
    # 10586 = First Major Update
    # 10240 = First Release
    $ForBuild = 15000

    If($BuildVer -lt $ForBuild) {
        If($Build_Check -eq 1) {
            $BuildVer = $ForBuild
        } Else {
            $BuildCheck = "Failed"
            $DoNotRun = "Yes"
        }
    }

    If(!($WinEdition -eq "Microsoft Windows 10 Home" -or $WinEdition -eq "Microsoft Windows 10 Pro")) {
        If($Edition_Check -eq 1) {
            $WinEdition = "Microsoft Windows 10 Pro"
        } Else {
            $EditionCheck = "Failed"
            $DoNotRun = "Yes"
        }
    }

    If($DoNotRun -eq "Yes" -and $Automated -eq 0) {
        DisplayOutMenu "|---------------------------------------------------|" 14 0 1
        DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu "                      Error                      " 13 0 0 ;DisplayOutMenu " |" 14 0 1
        DisplayOutMenu "|---------------------------------------------------|" 14 0 1
        DisplayOutMenu "|                                                   |" 14 0 1

        If($BuildCheck -eq "Failed") {
            DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " Not a valid Build for this Script.              " 2 0 0 ;DisplayOutMenu " |" 14 0 1
            DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " Lowest Build Recommended is Creator's Update    " 2 0 0 ;DisplayOutMenu " |" 14 0 1
            DisplayOutMenu "|                                                   |" 14 0 1
            DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " To skip change 'Build_Check' in script file.    " 11 0 0 ;DisplayOutMenu " |" 14 0 1
            DisplayOutMenu "|                                                   |" 14 0 1
        }

        If($EditionCheck -eq "Failed") {
            DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " Not a valid Windows Edition for this Script.    " 2 0 0 ;DisplayOutMenu " |" 14 0 1
            DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " Windows 10 Home and Pro Only                    " 2 0 0 ;DisplayOutMenu " |" 14 0 1
            DisplayOutMenu "|                                                   |" 14 0 1
            DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " To skip change 'Edition_Check' in script file   " 11 0 0 ;DisplayOutMenu " |" 14 0 1
            DisplayOutMenu "|                                                   |" 14 0 1
        }
        DisplayOutMenu "|---------------------------------------------------|" 14 0 1
        Write-Host ""
        Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
        $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
        Exit
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
                $WebScriptVer = $($CSV_Ver[0].Version)

                If($Service_Ver_Check -eq 1 -and $($CSV_Ver[1].Version) -gt $($csv[0]."Def-Home")) {
                    DownloadFile $Service_Url $ServiceFilePath
                }

                If($Script_Ver_Check -eq 1 -and $WebScriptVer -gt $Script_Version) {
                    $WebScriptFilePath = $filebase + "\BlackViper-Win10-Ver." + $($CSV_Ver[0].Version) + ".ps1"
                    DownloadFile $Script_Url $WebScriptFilePath
                    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$WebScriptFilePath`" $args" -Verb RunAs
                    Exit
                }
            } ElseIf($Automated -eq 0) {
                Clear-Host
                DisplayOutMenu "|---------------------------------------------------|" 14 0 1
                DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu "                      Error                      " 13 0 0 ;DisplayOutMenu " |" 14 0 1
                DisplayOutMenu "|---------------------------------------------------|" 14 0 1
                DisplayOutMenu "|                                                   |" 14 0 1
                DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu "No internet connection dectected.                " 2 0 0 ;DisplayOutMenu " |" 14 0 1
                DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu "Tested by pinging google.com and yahoo.com       " 2 0 0 ;DisplayOutMenu " |" 14 0 1
                DisplayOutMenu "|                                                   |" 14 0 1
                DisplayOutMenu "|---------------------------------------------------|" 14 0 1
                Write-Host ""
                Write-Host "Press Any key to Close..." -ForegroundColor White -BackgroundColor Black
                $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC")
            }
        }
        $ServiceDate = ($csv[0]."Def-Pro")
        $csv.RemoveRange(0,1)
    }
    ScriptPreStart
}

Function ScriptPreStart {
    If($SettingImp -ne $null -and $SettingImp) {
        $Automated = 1
        If($SettingImp -In 1..3) {
            Black_Viper_Set $SettingImp
        } ElseIf($SettingImp.ToLower() -eq "default") {
            Black_Viper_Set 1
        } ElseIf($SettingImp.ToLower() -eq "safe") {
            Black_Viper_Set 2
        } ElseIf($SettingImp.ToLower() -eq "tweaked") {
            Black_Viper_Set 3
        } Else {
            Clear-Host
            DisplayOutMenu "|---------------------------------------------------|" 14 0 1
            DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu "             Error Invalid Selection             " 13 0 0 ;DisplayOutMenu " |" 14 0 1
            DisplayOutMenu "|---------------------------------------------------|" 14 0 1
            DisplayOutMenu "|                                                   |" 14 0 1
            DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " Valid Swiches are:                              " 2 0 0 ;DisplayOutMenu " |" 14 0 1
            DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " 1 or Default                                    " 2 0 0 ;DisplayOutMenu " |" 14 0 1
            DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " 2 or Safe                                       " 2 0 0 ;DisplayOutMenu " |" 14 0 1
            DisplayOutMenu "| " 14 0 0 ;DisplayOutMenu " 3 or Tweaked                                    " 2 0 0 ;DisplayOutMenu " |" 14 0 1
            DisplayOutMenu "|                                                   |" 14 0 1
            DisplayOutMenu "|---------------------------------------------------|" 14 0 1
        }
    } ElseIf($Accept_TOS -eq 0) {
        TOS
    } Else {
        Black_Viper_Input
    }
}

# --------------------------------------------------------------------------

#----Safe to change Variables----
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
$Script:Show_Changed = 1        #0 = Dont Show Changed Services
                                #1 = Show Changed Services

$Script:Show_Already_Set = 1    #0 = Dont Show Already set Services
                                #1 = Show Already set Services

$Script:Show_Non_Installed = 0  #0 = Dont Show Services not present
                                #1 = Show Services not present
#--------------------------------

#----CHANGE AT YOUR OWN RISK!----
$Script:Internet_Check = 0      #0 = Checks if you have internet by doing a ping to google.com and yahoo.com
                                #1 = Bypass check if you have google.com and yahoo.com blocked
								
$Script:Edition_Check = 0       #0 = Check if Home or Pro Edition
                                #1 = Allows you to run on non Home/Pro

$Script:Build_Check = 0         #0 = Check Build (Creator's Update Minimum)
                                #1 = Allows you to run on Non-Creator's Update
#--------------------------------

# --------------------------------------------------------------------------

#Starts the script (Do not change)
PreScriptCheck
