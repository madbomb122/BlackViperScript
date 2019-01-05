##########
# Win 10 Black Viper Service Configuration Script
#
# Script + Menu(GUI) By
#  Author: Madbomb122
# Website: https://GitHub.com/Madbomb122/BlackViperScript/
#
# Black Viper's Service Configurations By
#  Author: Charles "Black Viper" Sparks
# Website: http://www.BlackViper.com/
#
$Script_Version = '5.4.4'
$Script_Date = 'Jan-05-2018'
#$Release_Type = 'Stable'
##########

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!                                         !!
# !!            SAFE TO EDIT ITEM            !!
# !!           AT BOTTOM OF SCRIPT           !!
# !!                                         !!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!                                         !!
# !!                 CAUTION                 !!
# !!       DO NOT EDIT PAST THIS POINT       !!
# !!                                         !!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

<#------------------------------------------------------------------------------#>
$Copyright =' Copyright (c) 2019 Zero Rights Reserved                                
          - Services Configuration by Charles "Black Viper" Sparks      
                                                                        
------------------------------------------------------------------------
                                                                        
 The MIT License (MIT) + an added Condition                             
                                                                        
 Copyright (c) 2017-2019 Madbomb122                                     
          - Black Viper Service Script                                  
                                                                        
 Permission is hereby granted, free of charge, to any person obtaining  
 a copy of this software and associated documentation files (the        
 "Software"), to deal in the Software without restriction, including    
 without limitation the rights to use, copy, modify, merge, publish,    
 distribute, sublicense, and/or sell copies of the Software, and to     
 permit persons to whom the Software is furnished to do so, subject to  
 the following conditions:                                              
                                                                        
 The above copyright notice(s), this permission notice and ANY original 
 donation link shall be included in all copies or substantial portions  
 of the Software.                                                       
                                                                        
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY  
 KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE 
 WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR    
 PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS 
 OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR   
 OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
 OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE  
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.     
                                                            '
<#--------------------------------------------------------------------------------

.Prerequisite to run script
	System*: Windows 10 x64 (64-bit)
	Edition*: Home or Pro
	Min Build*: Creator's Update
	Max Build*: April 2018 Update
	Files: This script and 'BlackViper.csv' (Service Configurations)
  *Can run on x32/32-bit or other Edition, Build AT YOUR OWN RISK)

.DESCRIPTION
	Script that can set services based on Black Viper's Service Configurations
	or your own custom services, or backup services (created by this script)

.AT YOUR OWN RISK YOU CAN
	1. Run the script on x86 (32-bit) w/o changing settings (But shows a warning)
	2. Skip the check for
		A. Home/Pro ($EditionCheck variable bottom of script or use -sec switch)
		B. Creator's Update ($BuildCheck variable bottom of script or use -sbc switch)

.BASIC USAGE
	1. Run script with (Next Line)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1
	2. Use bat file provided

	Use Gui to Select the desired Choices and click Run

.ADVANCED USAGE
	One of the following Methods...
	1. Edit values at bottom of the script then run script
	2. Edit bat file and run
	3. Run the script with one of these switches (space between multiple)
	4. Run the script and pick options in GUI

  Switch          Description of Switch
-- Basic Switches --
  -atos            Accepts ToS
  -auto            Implies -atos...Runs the script to be Automated.. Closes on - User Input, Errors, or End of Script

--Service Configuration Switches--
  -default         Runs the script with Services to Default Configuration
  -safe            Runs the script with Services to Black Viper's Safe Configuration
  -tweaked         Runs the script with Services to Black Viper's Tweaked Configuration
  -lcsc File.csv   Loads Custom Service Configuration, File.csv = Name of your backup/custom file

--Service Choice Switches--
  -all             Every windows services will change
  -min             Just the services different from the default to safe/tweaked list
  -sxb             Skips changes to all XBox Services

--Update Switches--
  -usc             Checks for Update to Script file before running
  -use             Checks for Update to Service file before running
  -sic             Skips Internet Check, if you can't ping GitHub.com for some reason

--Log Switches--
  -log             Makes a log file using default name Script.log
  -log File.log    Makes a log file named File.log
  -baf             Log File of Services Configuration Before and After the script

--Backup Service Configuration--
  -bscc            Backup Current Service Configuration, Csv File
  -bscr            Backup Current Service Configuration, Reg File
  -bscb            Backup Current Service Configuration, Csv and Reg File

--Display Switches--
  -sas             Show Already Set Services
  -snis            Show Not Installed Services
  -sss             Show Skipped Services

--Misc Switches--
  -dry             Runs the Script and Shows what services will be changed
  -css             Change State of Service
  -sds             Stop Disabled Service

--AT YOUR OWN RISK Switches--
  -secp            Skips Edition Check by Setting Edition as Pro
  -sech            Skips Edition Check by Setting Edition as Home
  -sbc             Skips Build Check

--Dev Switches--
  -devl            Makes a log file with various Diagnostic information, Nothing is Changed
  -diag            Shows diagnostic information, Stops -auto
  -diagf           Forced diagnostic information, Script does nothing else

--Help--
  -help            Shows list of switches, then exits script.. alt -h
  -copy            Shows Copyright/License Information, then exits script

------------------------------------------------------------------------------#>

##########
# Pre-Script/Needed Variable -Start
##########

$WindowVersion = [Environment]::OSVersion.Version.Major
If($WindowVersion -ne 10) {
	Write-Host 'Sorry, this Script supports Windows 10 ONLY.' -ForegroundColor 'cyan' -BackgroundColor 'black'
	If($Automated -ne 1){ Read-Host -Prompt "`nPress Any key to Close..." } ;Exit
}

If($Release_Type -eq 'Stable'){ $ErrorActionPreference = 'SilentlyContinue' } Else{ $Release_Type = 'Testing' }

$PassedArg = $args

If(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PassedArg" -Verb RunAs ;Exit
}

$PCType = (Get-CimInstance Win32_ComputerSystem).PCSystemType
$CimOS = Get-CimInstance Win32_OperatingSystem | Select-Object OperatingSystemSKU,Caption,BuildNumber,OSArchitecture

$OSBit = $CimOS.OSArchitecture

$WinSku = $CimOS.OperatingSystemSKU
$WinSkuList = @(48,49,98,100,101)
# 48 = Pro, 49 = Pro N
# 98 = Home N, 100 = Home (Single Language), 101 = Home

$FullWinEdition = $CimOS.Caption
$WinEdition = $FullWinEdition.Split(' ')[-1]
# Pro or Home

# https://en.wikipedia.org/wiki/Windows_10_version_history
$BuildVer = $CimOS.BuildNumber

$Win10Ver = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ReleaseID).ReleaseId
$MaxVer = 1803 ;$MaxVerName = 'April 2018 Update'
# 1809 = October 2018 Update
# 1803 = April 2018 Update
# 1709 = Fall Creators Update
$MinVer = 1703 ;$MinVerName = 'Creators Update'
# 1607 = Anniversary Update
# 1511 = November Update (First Major Update)
# 1507 = First Release

$URL_Base = 'https://raw.GitHub.com/madbomb122/BlackViperScript/master/'
$Version_Url = $URL_Base + 'Version/Version.csv'
$Service_Url = $URL_Base + 'BlackViper.csv'
$Donate_Url = 'https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/'
$MySite = 'https://GitHub.com/madbomb122/BlackViperScript'

$ServiceEnd = (Get-Service *_*).Where({$_.ServiceType -eq 224}, 'First') -Replace '^.+?_', '_'

$colors = @(
'black',      #0
'blue',       #1
'cyan',       #2
'darkblue',   #3
'darkcyan',   #4
'darkgray',   #5
'darkgreen',  #6
'darkmagenta',#7
'darkred',    #8
'darkyellow', #9
'gray',       #10
'green',      #11
'magenta',    #12
'red',        #13
'white',      #14
'yellow')     #15

$colorsGUI = @()
$colorsGUI += $colors
$colorsGUI[0] = 'white'
$colorsGUI[14] = 'black'
$colorsGUI[1] = 'yellow'
$colorsGUI[15] = 'blue'
$colorsGUI[2] = 'darkmagenta'
$colorsGUI[7] = 'cyan'


$ServicesTypeList = @(
'Skip',    #0 -Skip/Not Installed
'Disabled',#1
'Manual',  #2
'Auto',    #3
'Auto')    #4 -Auto (Delayed)

$ServicesTypeFull = @()
$ServicesTypeFull += $ServicesTypeList
$ServicesTypeFull[4] += ' (Delayed)'

$ServicesRegTypeList = @(
'', #0 -None
'4',#1 -Disable
'3',#2 -Manual
'2',#3 -Auto
'2')#4 -Auto (Delayed)

$SrvStateList = @('Running','Stopped')
$EBErrLst = @('','Edition','Build','Edition & Build')
$XboxServiceArr = @('XblAuthManager','XblGameSave','XboxNetApiSvc','XboxGipSvc','xbgm')
$NetTCP = @('NetMsmqActivator','NetPipeActivator','NetTcpActivator')
$FilterList = @('CheckboxChecked','CName','ServiceName','CurrType','BVType','SrvState','SrvDesc','SrvPath')
$DevLogList = @('WPF_ScriptLog_CB','WPF_Diagnostic_CB','WPF_LogBeforeAfter_CB','WPF_DryRun_CB','WPF_ShowNonInstalled_CB','WPF_ShowAlreadySet_CB')

$FileBase = $PSScriptRoot + '\'
$SettingPath = $FileBase + 'BVSetting.xml'
$ServiceFilePath = $FileBase + 'BlackViper.csv'
$BVServiceFilePath = $ServiceFilePath

$Black_Viper = 0
$Automated = 0
$All_or_Min = '-Min'
$RunScript = 2
$ErrorDi = ''
$LogStarted = 0
$LoadServiceConfig = 0
$RanScript = $False
$LaptopTweaked = 0
$ErrCount = $Error.Count
$GuiSwitch = $False
$StopWatch = New-Object System.Diagnostics.Stopwatch

[System.Collections.ArrayList]$ArgList = @{}
$ArgList += [PSCustomObject] @{ Arg = '-all' ;Var = 'All_or_Min=-Full';Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-min' ;Var = 'All_or_Min=-Min' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-bscc' ;Var = @('BackupServiceConfig=1','BackupServiceType=1') ;Match = 2 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-bscr' ;Var = @('BackupServiceConfig=1','BackupServiceType=0') ;Match = 2 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-bscb' ;Var = @('BackupServiceConfig=1','BackupServiceType=2') ;Match = 2 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-baf' ;Var = 'LogBeforeAfter=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-snis' ;Var = 'ShowNonInstalled=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-sss' ;Var = 'ShowSkipped=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-sas' ;Var = 'ShowAlreadySet=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-sds' ;Var = 'StopDisabled=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-sic' ;Var = 'InternetCheck=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-css' ;Var = 'ChangeState=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-usc' ;Var = 'ScriptVerCheck=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-use' ;Var = 'ServiceVerCheck=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-atos' ;Var = 'AcceptToS=Accepted' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-dry' ;Var = 'DryRun=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-devl' ;Var = 'DevLog=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-sbc' ;Var = 'BuildCheck=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-sxb' ;Var = 'XboxService=1' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-sech' ;Var = 'EditionCheck=Home' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-secp' ;Var = 'EditionCheck=Pro' ;Match = 1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-sec' ;Var = 'EditionCheck=Pro' ;Match = -1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-default' ;Var = @('Black_Viper=1','BV_ArgUsed=2') ;Match = 1 ;Gui = $False }
$ArgList += [PSCustomObject] @{ Arg = '-safe' ;Var = @('Black_Viper=2','BV_ArgUsed=2') ;Match = 1 ;Gui = $False }
$ArgList += [PSCustomObject] @{ Arg = '-tweaked' ;Var = If($PCType -eq 1){ @('Black_Viper=3','BV_ArgUsed=2') } Else{ @('Black_Viper=0','BV_ArgUsed=1') } ;Match = 1 ;Gui = $False }
$ArgList += [PSCustomObject] @{ Arg = '-auto' ;Var = @('Automated=1','AcceptToS=Accepted') ;Match = 1 ;Gui = $False }
$ArgList += [PSCustomObject] @{ Arg = '-diag' ;Var = @('Diagnostic=1','Automated=0') ;Match = 2 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-log' ;Var = @('ScriptLog=1','LogName=-') ;Match = -1 ;Gui = $True }
$ArgList += [PSCustomObject] @{ Arg = '-logc' ;Var = @('ScriptLog=2','LogName=-') ;Match = -1 ;Gui = $True }

##########
# Pre-Script/Needed Variable -End
##########
# Multi Use Functions -Start
##########

Function ThanksDonate {
	DisplayOut "`nThanks for using my script." -C 11
	DisplayOut 'If you like this script please consider giving me a donation,' -C 11
	DisplayOut 'Min of `$1 from the adjustable Amazon Gift Card.' -C 11
	DisplayOut "`nLink to donation:" -C 15
	DisplayOut $Donate_Url -C 2
}

Function AutomatedExitCheck([Int]$ExitBit) {
	If($Automated -ne 1){ Read-Host -Prompt "`nPress Any key to Close..." }
	If($ExitBit -eq 1){ LogEnd ;CloseExit }
}

Function LogEnd{ If(0 -NotIn $ScriptLog,$LogStarted){ Write-Output "--End of Log ($(Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt'))--" | Out-File -LiteralPath $LogFile -Encoding Unicode -NoNewline -Append } }
Function GetTime{ Return Get-Date -Format 'hh:mm:ss tt' }
Function CloseExit{ If($GuiSwitch){ $Form.Close() } ;Exit }
Function GetAllServices{ GetCurrServices ;$Script:AllService = $CurrServices | Select-Object Name, StartType, Status }
Function GetCurrServices{ $Script:CurrServices = Get-CimInstance Win32_service | Select-Object DisplayName, Name, @{ Name = 'StartType' ;Expression = {$_.StartMode} }, @{ Name = 'Status' ;Expression = {$_.State} }, Description, PathName }
Function OpenWebsite([String]$Url){ [System.Diagnostics.Process]::Start($Url) }
Function ShowInvalid([Bool]$InvalidA){ If($InvalidA){ Write-Host "`nInvalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline } Return $False }
Function DownloadFile([String]$Url,[String]$FilePath){ (New-Object System.Net.WebClient).DownloadFile($Url, $FilePath) }
Function QMarkServices([String]$Srv){ If($Srv -Match '_\?+$'){ Return ($Srv -Replace '_\?+$',$ServiceEnd) } Return $Srv }
Function SearchSrv([String]$Srv,[String]$Fil){ Return ($CurrServices.Where({$_.Name -eq $Srv}, 'First')).$Fil }
Function AutoDelayTest([String]$Srv){ $tmp = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$Srv\").DelayedAutostart ;If($null -ne $tmp){ Return $tmp } Return 0 }
Function AutoDelaySet([String]$Srv,[Int]$EnDi){ Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\$Srv\" -Name 'DelayedAutostart' -Type DWord -Value $EnDi }

Function DisplayOut {
	Param (
		[Alias('T')] [String[]]$Text,
		[Alias('C')] [Int[]]$Color,
		[Alias('L')] [Switch]$Log,
		[Alias('G')] [Switch]$Gui
	)
	If($Gui){ TBoxService @args }
	For($i=0 ;$i -lt $Text.Length ;$i++){ Write-Host $Text[$i] -ForegroundColor $colors[$Color[$i]] -BackgroundColor 'Black' -NoNewLine } ;Write-Host
	If($Log -and $ScriptLog -eq 1){ Write-Output "$(GetTime): $($Text -Join ' ')" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append }
}

Function DisplayOutLML {
	Param (
		[Alias('T')] [String]$Text,
		[Alias('C')] [Int]$Color,
		[Alias('L')] [Switch]$Log
	)
	DisplayOut '| ',"$Text".PadRight(50),' |' -C 14,$Color,14 -L:$Log
}

$MLine = '|'.PadRight(53,'-') + '|'
$MBLine = '|'.PadRight(53) + '|'

Function MenuLine([Switch]$L){ DisplayOut $MLine -C 14 -L:$L }
Function MenuBlankLine([Switch]$L){ DisplayOut $MBLine -C 14 -L:$L }

Function Error_Top {
	Clear-Host
	DiagnosticCheck 0
	MenuLine -L
	DisplayOutLML (''.PadRight(22)+'Error') -C 13 -L
	MenuLine -L
	MenuBlankLine -L
}

Function Error_Bottom {
	MenuBlankLine -L
	MenuLine -L
	If($Diagnostic -eq 1){ DiagnosticCheck 0 }
	AutomatedExitCheck 1
}

##########
# Multi Use Functions -End
##########
# TOS -Start
##########

Function TOSLine([Int]$BC){ DisplayOut $MLine -C $BC}
Function TOSBlankLine([Int]$BC){ DisplayOut $MBLine -C $BC }
Function ShowCopyright { Clear-Host ;DisplayOut $Copyright -C 14 }

Function TOSDisplay([Switch]$C) {
	If(!$C){ Clear-Host }
	$BC = 14
	If($Release_Type -ne 'Stable') {
		$BC = 15
		TOSLine 15
		DisplayOut '|'.PadRight(22),'Caution!!!'.PadRight(31),'|' -C 15,13,15
		TOSBlankLine 15
		DisplayOut '|','         This script is still being tested.         ','|' -C 15,14,15
		DisplayOut '|'.PadRight(17),'USE AT YOUR OWN RISK.'.PadRight(36),'|' -C 15,14,15
		TOSBlankLine 15
	}
	If($OSBit -ne '64-bit') {
		$BC = 15
		TOSLine 15
		DisplayOut '|'.PadRight(22),'WARNING!!!'.PadRight(31),'|' -C 15,13,15
		TOSBlankLine 15
		DisplayOut '|','        These settings are ment for x64 Bit.        ','|' -C 15,14,15
		DisplayOut '|'.PadRight(17),'USE AT YOUR OWN RISK.'.PadRight(36),'|' -C 15,14,15
		TOSBlankLine 15
	}
	TOSLine $BC
	DisplayOut '|'.PadRight(21),'Terms of Use'.PadRight(32),'|' -C $BC,11,$BC
	TOSLine $BC
	TOSBlankLine $BC
	DisplayOut '|',' This program comes with ABSOLUTELY NO WARRANTY.    ','|' -C $BC,2,$BC
	DisplayOut '|',' This is free software, and you are welcome to      ','|' -C $BC,2,$BC
	DisplayOut '|',' redistribute it under certain conditions.          ','|' -C $BC,2,$BC
	TOSBlankLine $BC
	DisplayOut '|',' Read License file for full Terms.'.PadRight(52),'|' -C $BC,2,$BC
	TOSBlankLine $BC
	DisplayOut '|',' Use the switch ','-copy',' to see License Information or ','|' -C $BC,2,14,2,$BC
	DisplayOut '|',' enter ','L',' bellow.'.PadRight(44),'|' -C $BC,2,14,2,$BC
	TOSBlankLine $BC
	TOSLine $BC
}

Function TOS {
	$Invalid = $False
	$CopyR = $False
	While($TOS -ne 'Out') {
		TOSDisplay -C:$CopyR
		$CopyR = $False
		$Invalid = ShowInvalid $Invalid
		$TOS = Read-Host "`nDo you Accept? (Y)es/(N)o"
		$TOS = $TOS.ToLower()
		If($TOS -In 'n','no') {
			Exit
		} ElseIf($TOS -In 'y','yes') {
			$TOS = 'Out'
			$Script:AcceptToS = 'Accepted'
			$Script:RunScript = 1
			If($LoadServiceConfig -eq 1){ Black_Viper_Set } ElseIf($Black_Viper -eq 0){ GuiStart } Else{ Black_Viper_Set $Black_Viper $All_or_Min }
		} ElseIf($TOS -eq 'l') {
			$CopyR = $True ;ShowCopyright
		} Else {
			$Invalid = $True
		}
	} Return
}

##########
# TOS -End
##########
# GUI -Start
##########

Function OpenSaveDiaglog([Int]$SorO) {
	If($SorO -eq 0){ $SOFileDialog = New-Object System.Windows.Forms.OpenFileDialog } Else{ $SOFileDialog = New-Object System.Windows.Forms.SaveFileDialog }
	$SOFileDialog.InitialDirectory = $FileBase
	If($SorO -ne 2){ $SOFileDialog.Filter = 'CSV (*.csv)| *.csv' } Else{ $SOFileDialog.Filter = 'Registration File (*.reg)| *.reg' }
	$SOFileDialog.ShowDialog()
	$SOFPath = $SOFileDialog.Filename
	If($SOFPath) {
		If($SorO -eq 0) {
			$Script:ServiceConfigFile = $SOFPath ;$WPF_LoadFileTxtBox.Text = $ServiceConfigFile ;RunDisableCheck
		} ElseIf($SorO -eq 1) {
			Save_Service $SOFPath
		} ElseIf($SorO -eq 2) {
			RegistryServiceFile $SOFPath
		}
	}
}

Function HideShowCustomSrvStuff {
	If(($WPF_ServiceConfig.SelectedIndex+1) -eq $BVCount){ $Vis = 'Visible' ;$TF = $False } Else{ $Vis = 'Hidden' ;$TF = $True }
	$WPF_RadioAll.IsEnabled = $TF
	$WPF_RadioMin.IsEnabled = $TF
	$CNoteList.ForEach{ $_.Value.Visibility = $Vis }
	$WPF_LoadFileTxtBox.Visibility = $Vis
	$WPF_btnOpenFile.Visibility = $Vis
}

Function SetServiceVersion {
	If(Test-Path -LiteralPath $BVServiceFilePath -PathType Leaf) {
		$TMP = Import-Csv -LiteralPath $BVServiceFilePath
		$Script:ServiceVersion = $TMP[0].'Def-Home-Full'
		$Script:ServiceDate = $TMP[0].'Def-Home-Min'
		Return $True
	}
	$Script:ServiceVersion = 'Missing File'
	$Script:ServiceDate = 'BlackViper.csv'
	Return $False
}

Function ClickedDonate{ OpenWebsite $Donate_Url ;$Script:ConsideredDonation = 'Yes' }

Function UpdateSetting {
	$VarList.ForEach{
		If($_.Value.IsChecked){ $SetValue = 1 } Else{ $SetValue = 0 }
		Set-Variable -Name ($_.Name.Split('_')[1]) -Value $SetValue -Scope Script
	}
	If($WPF_RadioAll.IsChecked){ $Script:All_or_Min = '-Full' } Else{ $Script:All_or_Min = '-Min' }
	If($WPF_EditionCheckCB.IsChecked){ $Script:EditionCheck = $WPF_EditionConfig.Text }
	$Script:LogName = $WPF_LogNameInput.Text
	$Script:BackupServiceType = $WPF_BackupServiceType.SelectedIndex
}

Function SaveSetting {
	UpdateSetting

	$Black_Viper = $WPF_ServiceConfig.SelectedIndex
	If(($Black_Viper+1) -eq $BVCount -or ($IsLaptop -eq '-Lap' -and $LaptopTweaked -ne 1 -and $Black_Viper -ge 2)){ $Black_Viper = 0 }

	$Settings = @{}
	$Settings.AcceptToS = $AcceptToS
	$Settings.EditionCheck = $EditionCheck
	$Settings.BuildCheck = $BuildCheck
	$Settings.LaptopTweaked = $LaptopTweaked
	$Settings.Black_Viper = $Black_Viper
	$Settings.All_or_Min = $All_or_Min
	$Settings.BackupServiceConfig = $BackupServiceConfig
	$Settings.BackupServiceType = $BackupServiceType
	$Settings.InternetCheck = $InternetCheck
	$Settings.ScriptVerCheck = $ScriptVerCheck
	$Settings.ServiceVerCheck = $ServiceVerCheck
	$Settings.ShowConsole = $ShowConsole
	$Settings.XboxService = $XboxService
	$Settings.StopDisabled = $StopDisabled
	$Settings.ChangeState = $ChangeState
	$Settings.ShowSkipped = $ShowSkipped
	If($ConsideredDonation -eq 'Yes'){ $Settings.ConsideredDonation = 'Yes' }
	If($WPF_DevLogCB.IsChecked) {
		$Settings.ScriptLog = $Script_Log
		$Settings.LogName = $Log_Name
		$Settings.Diagnostic = $Diagn_ostic
		$Settings.LogBeforeAfter = $Log_Before_After
		$Settings.DryRun = $Dry_Run
		$Settings.ShowNonInstalled = $Show_Non_Installed
		$Settings.ShowAlreadySet = $Show_Already_Set
	} Else {
		$Settings.ScriptLog = $ScriptLog
		$Settings.LogName = $LogName
		$Settings.Diagnostic = $Diagnostic
		$Settings.LogBeforeAfter = $LogBeforeAfter
		$Settings.DryRun = $DryRun
		$Settings.ShowNonInstalled = $ShowNonInstalled
		$Settings.ShowAlreadySet = $ShowAlreadySet
	}

	If(Test-Path -LiteralPath $SettingPath -PathType Leaf) {
		$Tmp = (Import-Clixml -LiteralPath $SettingPath | ConvertTo-Xml).Objects.Object.Property."#text"
		If(($Tmp.Count/2) -eq $Settings.Count) {
			$T1 = While($Tmp){ $Key, $Val, $Tmp = $Tmp ;[PSCustomObject] @{ Name = $Key ;Val = $Val } }
			$Tmp = ($Settings | ConvertTo-Xml).Objects.Object.Property."#text"
			$T2 = While($Tmp){ $Key, $Val, $Tmp = $Tmp ;[PSCustomObject] @{ Name = $Key ;Val = $Val } }
			If(Compare-Object $T1 $T2 -Property Name,Val){ $SaveSettingFile = $True }
		} Else {
			$SaveSettingFile = $True
		}
	} Else {
		$SaveSettingFile = $True
	}
	If($SaveSettingFile){ $Settings | Export-Clixml -LiteralPath $SettingPath }
}

Function DevLogCBFunction([Bool]$C) {
	If(!$C) {
		$Script:ScriptLog = $Script_Log
		$Script:LogName = $Log_Name
		$Script:Diagnostic = $Diagn_ostic
		$Script:Automated = $Auto_mated
		$Script:LogBeforeAfter = $Log_Before_After
		$Script:DryRun = $Dry_Run
		$Script:ShowNonInstalled = $Show_Non_Installed
		$Script:ShowSkipped = $Show_Skipped
		$Script:ShowAlreadySet = $Show_Already_Set
	} Else {
		UpdateSetting
		$Script:Script_Log = $ScriptLog
		$Script:Log_Name = $LogName
		$Script:Diagn_ostic = $Diagnostic
		$Script:Auto_mated = $Automated
		$Script:Log_Before_After = $LogBeforeAfter
		$Script:Dry_Run = $DryRun
		$Script:Show_Non_Installed = $ShowNonInstalled
		$Script:Show_Skipped = $ShowSkipped
		$Script:Show_Already_Set = $ShowAlreadySet
		DevLogSet
	}
	$DevLogList.ForEach{
		$TmpWPF = Get-Variable -Name $_ -ValueOnly
		If((Get-Variable -Name ($_.Split('_')[1]) -ValueOnly) -eq 0){ $TmpWPF.IsChecked = $False } Else{ $TmpWPF.IsChecked = $True }
		$TmpWPF.IsEnabled = !$C
	}
	If($ScriptLog -eq 0 -or $C){ $WPF_LogNameInput.IsEnabled = $False } Else{ $WPF_LogNameInput.IsEnabled = $True }
	$WPF_LogNameInput.Text = $LogName
}

Function ShowConsoleWin([Int]$Choice){ [Console.Window]::ShowWindow($ConsolePtr, $Choice) }#0 = Hide, 5 = Show

Function GuiStart {
	#Needed to Hide Console window
	Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow() ;[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
	$Script:ConsolePtr = [Console.Window]::GetConsoleWindow()

	Clear-Host
	DisplayOut 'Preparing GUI, Please wait...' -C 15
	$Script:GuiSwitch = $True

[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Black Viper Service Configuration Script By: MadBomb122" Height="390" Width="670" BorderBrush="Black" Background="White">
	<Window.Resources>
		<Style x:Key="SeparatorStyle1" TargetType="{x:Type Separator}">
			<Setter Property="SnapsToDevicePixels" Value="True"/>
			<Setter Property="Margin" Value="0,0,0,0"/>
			<Setter Property="Template">
				<Setter.Value><ControlTemplate TargetType="{x:Type Separator}"><Border Height="24" SnapsToDevicePixels="True" Background="#FF4D4D4D" BorderBrush="#FF4D4D4D" BorderThickness="0,0,0,1"/></ControlTemplate></Setter.Value>
			</Setter>
		</Style>
		<Style TargetType="{x:Type ToolTip}"><Setter Property="Background" Value="#FFFFFFBF"/></Style>
	</Window.Resources>
	<Window.Effect><DropShadowEffect/></Window.Effect>
	<Grid>
		<Button Name="RunScriptButton" Content="Run Script" Margin="0,0,0,21" VerticalAlignment="Bottom" Height="20" FontWeight="Bold"/>
		<TextBlock Name="Script_Ver_Txt" HorizontalAlignment="Left" Height="20" VerticalAlignment="Bottom" Width="330" TextAlignment="Center"/>
		<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="330,0,0,0" Stroke="Black" Width="1" Height="20" VerticalAlignment="Bottom"/>
		<TextBlock Name="Service_Ver_Txt" HorizontalAlignment="Left" Height="20" VerticalAlignment="Bottom" Width="330" TextAlignment="Center" Margin="331,0,0,0"/>
		<TabControl Name="TabControl" Margin="0,22,0,42">
			<TabItem Name="Services_Tab" Header="Services Options" Margin="-2,0,2,0">
				<Grid Background="#FFE5E5E5">
					<Label Content="Service Configurations:" HorizontalAlignment="Left" Margin="2,63,0,0" VerticalAlignment="Top" Height="27" Width="146" FontWeight="Bold"/>
					<ComboBox Name="ServiceConfig" HorizontalAlignment="Left" Margin="139,66,0,0" VerticalAlignment="Top" Width="118" Height="23">
						<ComboBoxItem Content="Default" HorizontalAlignment="Left" Width="116" IsSelected="True"/>
						<ComboBoxItem Content="Safe" HorizontalAlignment="Left" Width="116"/>
						<ComboBoxItem Content="Tweaked" HorizontalAlignment="Left" Width="116"/>
						<ComboBoxItem Content="Custom Setting *" HorizontalAlignment="Left" Width="116"/>
					</ComboBox>
					<RadioButton Name="RadioAll" Content="All -Change All Services" HorizontalAlignment="Left" Margin="5,26,0,0" VerticalAlignment="Top" IsChecked="True"/>
					<RadioButton Name="RadioMin" Content="Min -Change Services that are Different from Default to Safe/Tweaked" HorizontalAlignment="Left" Margin="5,41,0,0" VerticalAlignment="Top"/>
					<Label Content="Black Viper Configuration Options (BV Services Only)" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="2,3,0,0" FontWeight="Bold"/>
					<Label Name="CustomNote1" Content="*Note: Configure Below" HorizontalAlignment="Left" Margin="262,63,0,0" VerticalAlignment="Top" Width="148" Height="27" FontWeight="Bold"/>
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,112,-6,0" Stroke="Black" VerticalAlignment="Top"/>
					<Button Name="btnOpenFile" Content="Browse File" HorizontalAlignment="Left" Margin="5,141,0,0" VerticalAlignment="Top" Width="66" Height="22"/>
					<TextBlock Name="LoadFileTxtBox" HorizontalAlignment="Left" Height="50" Margin="5,171,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="461" Background="#FFECECEC"/>
					<Label Name="CustomNote3" Content="Config File: Browse for file" HorizontalAlignment="Left" Margin="76,139,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
					<Label Name="CustomNote2" Content="Custom Configuration" HorizontalAlignment="Left" Margin="164,116,0,0" VerticalAlignment="Top" Width="135" Height="26" FontWeight="Bold"/>
				</Grid>
			</TabItem>
			<TabItem Name="ServicesCB_Tab" Header="Services List" Margin="-2,0,2,0">
				<Grid Background="#FFE5E5E5">
					<DataGrid Name="dataGrid" FrozenColumnCount="2" AutoGenerateColumns="False" AlternationCount="2" HeadersVisibility="Column" Margin="-2,66,-2,-2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">
						<DataGrid.RowStyle>
							<Style TargetType="{x:Type DataGridRow}"><Style.Triggers>
								<Trigger Property="AlternationIndex" Value="0"><Setter Property="Background" Value="White"/></Trigger>
								<Trigger Property="AlternationIndex" Value="1"><Setter Property="Background" Value="#FFD8D8D8"/></Trigger>
								<Trigger Property="IsMouseOver" Value="True">
									<Setter Property="ToolTip"><Setter.Value><TextBlock Text="{Binding SrvDesc}" TextWrapping="Wrap" Width="400" Background="#FFFFFFBF" Foreground="Black"/></Setter.Value></Setter>
									<Setter Property="ToolTipService.ShowDuration" Value="360000000"/>
								</Trigger>
								<MultiDataTrigger>
									<MultiDataTrigger.Conditions>
										<Condition Binding="{Binding checkboxChecked}" Value="True"/>
										<Condition Binding="{Binding Matches}" Value="False"/>
									</MultiDataTrigger.Conditions>
									<Setter Property="Background" Value="#F08080"/>
								</MultiDataTrigger>
								<MultiDataTrigger>
									<MultiDataTrigger.Conditions>
										<Condition Binding="{Binding checkboxChecked}" Value="False"/>
										<Condition Binding="{Binding Matches}" Value="False"/>
									</MultiDataTrigger.Conditions>
									<Setter Property="Background" Value="#FFFFFF64"/>
								</MultiDataTrigger>
								<MultiDataTrigger>
									<MultiDataTrigger.Conditions>
										<Condition Binding="{Binding checkboxChecked}" Value="True"/>
										<Condition Binding="{Binding Matches}" Value="True"/>
									</MultiDataTrigger.Conditions>
									<Setter Property="Background" Value="LightGreen"/>
								</MultiDataTrigger>
							</Style.Triggers></Style>
						</DataGrid.RowStyle>
						<DataGrid.Columns>
							<DataGridTemplateColumn SortMemberPath="checkboxChecked" CanUserSort="True">
								<DataGridTemplateColumn.Header><CheckBox Name="ACUcheckboxChecked" IsEnabled="False"/></DataGridTemplateColumn.Header>
								<DataGridTemplateColumn.CellTemplate><DataTemplate><CheckBox IsChecked="{Binding checkboxChecked,Mode=TwoWay,UpdateSourceTrigger=PropertyChanged,NotifyOnTargetUpdated=True}" IsEnabled="{Binding ElementName=CustomBVCB, Path=IsChecked}"/></DataTemplate></DataGridTemplateColumn.CellTemplate>
							</DataGridTemplateColumn>
							<DataGridTextColumn Header="Common Name" Width="121" Binding="{Binding CName}" CanUserSort="True" IsReadOnly="True"/>
							<DataGridTextColumn Header="Service Name" Width="120" Binding="{Binding ServiceName}" IsReadOnly="True"/>
							<DataGridTextColumn Header="Current Setting" Width="95" Binding="{Binding CurrType}" IsReadOnly="True"/>
							<DataGridTemplateColumn Header="Black Viper" Width="105" SortMemberPath="BVType" CanUserSort="True">
								<DataGridTemplateColumn.CellTemplate><DataTemplate>
									<ComboBox ItemsSource="{Binding ServiceTypeListDG}" Text="{Binding Path=BVType, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}" IsEnabled="{Binding ElementName=CustomBVCB, Path=IsChecked}"/></DataTemplate></DataGridTemplateColumn.CellTemplate>
								</DataGridTemplateColumn>
							<DataGridTemplateColumn Header="State" Width="80" SortMemberPath="SrvState" CanUserSort="True">
								<DataGridTemplateColumn.CellTemplate><DataTemplate>
									<ComboBox ItemsSource="{Binding SrvStateListDG}" Text="{Binding Path=SrvState, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}" IsEnabled="{Binding ElementName=CustomBVCB, Path=IsChecked}"/></DataTemplate></DataGridTemplateColumn.CellTemplate>
								</DataGridTemplateColumn>
							<DataGridTextColumn Header="Description" Width="120" Binding="{Binding SrvDesc}" CanUserSort="True" IsReadOnly="True"/>
							<DataGridTextColumn Header="Path" Width="120" Binding="{Binding SrvPath}" CanUserSort="True" IsReadOnly="True"/>
						</DataGrid.Columns>
					</DataGrid>
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="-2,66,-2,0" Stroke="Black" VerticalAlignment="Top"/>
					<Label Name="ServiceClickLabel" Content="&lt;-- Click to load Service List" HorizontalAlignment="Left" Margin="75,-3,0,0" VerticalAlignment="Top"/>
					<Button Name="LoadServicesButton" Content="Load Services" HorizontalAlignment="Left" Margin="2,1,0,0" VerticalAlignment="Top" Width="76"/>
					<Button Name="SaveCustomSrvButton" Content="Save Current" HorizontalAlignment="Left" Margin="81,1,0,0" VerticalAlignment="Top" Width="80" Visibility="Hidden"/>
					<Button Name="SaveRegButton" Content="Save Registry" HorizontalAlignment="Left" Margin="164,1,0,0" VerticalAlignment="Top" Width="80" Visibility="Hidden"/>
					<Label Name="ServiceNote" Content="Uncheck what you &quot;Don't want to be changed&quot;" HorizontalAlignment="Left" Margin="372,43,0,0" VerticalAlignment="Top" Visibility="Hidden"/>
					<CheckBox Name="CustomBVCB" Content="Customize Service" HorizontalAlignment="Left" Margin="248,4,0,0" VerticalAlignment="Top" Width="119" RenderTransformOrigin="0.696,0.4" Visibility="Hidden"/>
					<TextBlock Name="TableLegend" HorizontalAlignment="Left" Margin="373,0,-2,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="275" Height="46" FontWeight="Bold" Visibility="Hidden"><Run Background="LightGreen" Text=" Checked &amp; Service is Same as Current                  "/><LineBreak/><Run Background="LightCoral" Text=" Checked &amp; Service is NOT Same as Current          "/><LineBreak/><Run Background="#FFFFFF64" Text=" NOT Checked &amp; Service is NOT Same as Current "/></TextBlock>
					<Rectangle Name="Div1" Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="372,-2,0,0" Stroke="Black" Width="1" Height="48" VerticalAlignment="Top" Visibility="Hidden"/>
					<TextBox Name="FilterTxt" HorizontalAlignment="Left" Height="20" Margin="43,32,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="203" Visibility="Hidden"/>
					<ComboBox Name="FilterType" HorizontalAlignment="Left" Margin="248,30,0,0" VerticalAlignment="Top" Width="115" Height="25" Visibility="Hidden">
						<ComboBoxItem Content="Checked" HorizontalAlignment="Left" Width="115" Margin="0,0,-2,0"/>
						<ComboBoxItem Content="Common Name" HorizontalAlignment="Left" Width="115" IsSelected="True"/>
						<ComboBoxItem Content="Service Name" HorizontalAlignment="Left" Width="115"/>
						<ComboBoxItem Content="Current Setting" HorizontalAlignment="Left" Width="115"/>
					</ComboBox>
					<Rectangle Name="Div2" Fill="#FFFFFFFF" Height="1" Margin="372,46,-2,0" Stroke="Black" VerticalAlignment="Top" Visibility="Hidden"/>
					<Label Name="FilterLabel" Content="Search:" HorizontalAlignment="Left" Margin="-2,28,0,0" VerticalAlignment="Top" Visibility="Hidden"/>
				</Grid>
			</TabItem>
			<TabItem Name="Options_tab" Header="Script Options" Margin="-2,0,2,0">
				<Grid Background="#FFE5E5E5">
					<Label Content="Display Options" HorizontalAlignment="Left" Margin="2,-2,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
					<CheckBox Name="ShowAlreadySet_CB" Content="Show Already Set Services" HorizontalAlignment="Left" Margin="7,20,0,0" VerticalAlignment="Top" Height="15" Width="158" IsChecked="True"/>
					<CheckBox Name="ShowNonInstalled_CB" Content="Show Not Installed Services" HorizontalAlignment="Left" Margin="7,35,0,0" VerticalAlignment="Top" Height="15" Width="166"/>
					<CheckBox Name="ShowSkipped_CB" Content="Show Skipped Services" HorizontalAlignment="Left" Margin="7,50,0,0" VerticalAlignment="Top" Height="15" Width="144"/>
					<Label Content="SKIP CHECK AT YOUR OWN RISK!" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="233,-2,0,0" FontWeight="Bold"/>
					<CheckBox Name="BuildCheck_CB" Content="Skip Build Check" HorizontalAlignment="Left" Margin="236,22,0,0" VerticalAlignment="Top" Height="15" Width="110"/>
					<CheckBox Name="EditionCheckCB" Content="Skip Edition Check Set as :" HorizontalAlignment="Left" Margin="236,37,0,0" VerticalAlignment="Top" Height="15" Width="160"/>
					<ComboBox Name="EditionConfig" HorizontalAlignment="Left" Margin="395,34,0,0" VerticalAlignment="Top" Width="60" Height="23">
						<ComboBoxItem Content="Home" HorizontalAlignment="Left" Width="58"/>
						<ComboBoxItem Content="Pro" HorizontalAlignment="Left" Width="58" IsSelected="True"/>
					</ComboBox>
					<Label Content="Log Options" HorizontalAlignment="Left" Margin="461,-2,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
					<CheckBox Name="LogBeforeAfter_CB" Content="Services Before and After" HorizontalAlignment="Left" Margin="466,22,0,0" VerticalAlignment="Top" Height="16" Width="158"/>
					<CheckBox Name="ScriptLog_CB" Content="Script Log:" HorizontalAlignment="Left" Margin="466,37,0,0" VerticalAlignment="Top" Height="18" Width="76"/>
					<TextBox Name="LogNameInput" HorizontalAlignment="Left" Height="20" Margin="543,36,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="105" IsEnabled="False"/>
					<Label Content="Misc Options" HorizontalAlignment="Left" Margin="2,66,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
					<CheckBox Name="Dryrun_CB" Content="Dryrun -Shows what will be changed" HorizontalAlignment="Left" Margin="7,89,0,0" VerticalAlignment="Top" Height="15" Width="213"/>
					<CheckBox Name="XboxService_CB" Content="Skip All Xbox Services" HorizontalAlignment="Left" Margin="7,104,0,0" VerticalAlignment="Top" Height="15" Width="137"/>
					<CheckBox Name="ChangeState_CB" Content="Allow Change of Service State" HorizontalAlignment="Left" Margin="7,119,0,0" VerticalAlignment="Top" Height="15" Width="181"/>
					<CheckBox Name="StopDisabled_CB" Content="Stop Disabled Services" HorizontalAlignment="Left" Margin="7,134,0,0" VerticalAlignment="Top" Height="15" Width="144"/>
					<CheckBox Name="BackupServiceConfig_CB" Content="Backup Current Service as:" HorizontalAlignment="Left" Margin="7,149,0,0" VerticalAlignment="Top" Height="15" Width="162"/>
					<ComboBox Name="BackupServiceType" HorizontalAlignment="Left" Margin="169,145,0,0" VerticalAlignment="Top" Width="52" Height="23">
						<ComboBoxItem Content=".reg" HorizontalAlignment="Left" Width="50"/>
						<ComboBoxItem Content=".csv" HorizontalAlignment="Left" Width="50" IsSelected="True"/>
						<ComboBoxItem Content="Both" HorizontalAlignment="Left" Width="50"/>
					</ComboBox>
					<Label Content="Dev Options" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="2,168,0,0" FontWeight="Bold"/>
					<CheckBox Name="Diagnostic_CB" Content="Diagnostic Output (On Error)" HorizontalAlignment="Left" Margin="7,190,0,0" VerticalAlignment="Top" Height="15" Width="174"/>
					<CheckBox Name="DevLogCB" Content="Dev Log" HorizontalAlignment="Left" Margin="7,205,0,0" VerticalAlignment="Top" Height="15" Width="174"/>
					<CheckBox Name="ShowConsole_CB" Content="Show Console Window" HorizontalAlignment="Left" Margin="7,220,0,0" VerticalAlignment="Top" Height="15" Width="144"/>
					<Button Name="ShowDiagButton" Content="Show Diagnostic" HorizontalAlignment="Left" Margin="48,237,0,0" VerticalAlignment="Top" Width="101" Background="#FF98D5FF"/>
					<Label Content="Update Items" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="231,66,0,0" FontWeight="Bold"/>
					<CheckBox Name="ServiceVerCheck_CB" Content="Auto Service Update" HorizontalAlignment="Left" Margin="236,91,0,0" VerticalAlignment="Top" Height="15" Width="131"/>
					<CheckBox Name="ScriptVerCheck_CB" Content="Auto Script Update*" HorizontalAlignment="Left" Margin="236,106,0,0" VerticalAlignment="Top" Height="15" Width="126"/>
					<CheckBox Name="InternetCheck_CB" Content="Skip Internet Check" HorizontalAlignment="Left" Margin="236,121,0,0" VerticalAlignment="Top" Height="15" Width="124"/>
					<Label Content="*Will run and use current settings&#xA;&#xD;&#xA;Note: Update checks happen before &#xA;          services are changed." HorizontalAlignment="Left" Margin="233,137,0,0" VerticalAlignment="Top" FontWeight="Bold" Width="220"/>
					<Label Content="Check for Update Now for:" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="464,66,0,0" FontWeight="Bold"/>
					<Button Name="CheckUpdateSerButton" Content="Services" HorizontalAlignment="Left" Margin="494,90,0,0" VerticalAlignment="Top" Width="109"/>
					<Button Name="CheckUpdateSrpButton" Content="Script*" HorizontalAlignment="Left" Margin="494,115,0,0" VerticalAlignment="Top" Width="109"/>
					<Button Name="CheckUpdateBothButton" Content="Services &amp; Script*" HorizontalAlignment="Left" Margin="494,140,0,0" VerticalAlignment="Top" Width="109"/>
					<Label Content="*Wont remember Settings in&#xD;&#xA;'Service Options' or 'Services&#xD;&#xA;List' Tab" HorizontalAlignment="Left" Margin="464,159,0,0" VerticalAlignment="Top" FontWeight="Bold" Width="177" Height="61"/>
					<CheckBox Name="LaptopTweaked_CB" Content="Enable Tweak Setting on non-Desktop**" HorizontalAlignment="Left" Margin="235,216,0,0" VerticalAlignment="Top" Height="15" Width="236"/>
					<Label Name="LaptopTweaked_txt" Content="**CAUTION: Use this with EXTREME CAUTION" HorizontalAlignment="Left" Margin="259,226,0,0" VerticalAlignment="Top" FontWeight="Bold" Width="268"/>
					<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="229,0,0,0" Stroke="Black" Width="1"/>
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="-6,172,0,0" Stroke="Black" VerticalAlignment="Top" HorizontalAlignment="Left" Width="235"/>
					<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="459,0,0,0" Stroke="Black" Width="1" Height="212" VerticalAlignment="Top"/>
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="230,212,0,0" Stroke="Black" VerticalAlignment="Top"/>
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="-6,69,0,0" Stroke="Black" VerticalAlignment="Top" HorizontalAlignment="Left" Width="662"/>
				</Grid>
			</TabItem>
			<TabItem Name="ServiceChanges" Header="Service Changes" Margin="-2,0,2,0" Visibility="Hidden">
				<Grid Background="#FFE5E5E5">
					<ScrollViewer VerticalScrollBarVisibility="Visible"><TextBlock Name="ServiceListing" TextTrimming="CharacterEllipsis" Background="White"/></ScrollViewer>
				</Grid>
			</TabItem>
			<TabItem Name="DiagnosticTab" Header="Diagnostic" Margin="-2,0,2,0" Visibility="Hidden">
				<Grid Background="#FFE5E5E5">
					<ScrollViewer VerticalScrollBarVisibility="Visible"><TextBlock Name="DiagnosticOutput" TextTrimming="CharacterEllipsis" Background="White"/></ScrollViewer>
				</Grid>
			</TabItem>
		</TabControl>
		<Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,0,0,41" Stroke="Black" VerticalAlignment="Bottom"/>
		<Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,0,0,20" Stroke="Black" VerticalAlignment="Bottom"/>
		<Menu Height="22" VerticalAlignment="Top">
			<MenuItem Header="Help" Height="22" Width="34" Padding="3,0,0,0">
				<MenuItem Name="FeedbackButton" Header="Feedback/Bug Report" Height="22" Background="#FFF0F0F0" Padding="-20,0,-40,0"/>
				<MenuItem Name="FAQButton" Header="FAQ" Height="22" Padding="-20,0,0,0" Background="#FFF0F0F0"/>
				<MenuItem Name="AboutButton" Header="About" Height="22" Padding="-20,0,0,0" Background="#FFF0F0F0"/>
				<MenuItem Name="CopyrightButton" Header="Copyright" Height="22" Padding="-20,0,0,0" Background="#FFF0F0F0"/>
				<Separator Height="2" Margin="-30,0,0,0"/>
				<MenuItem Name="ContactButton" Header="Contact Me" Height="22" Padding="-20,0,0,0" Background="#FFF0F0F0"/>
			</MenuItem>
			<Separator Width="2" Style="{DynamicResource SeparatorStyle1}"/>
			<MenuItem Name="DonateButton" Header="Donate to Me" Height="24" Width="88" Background="Orange" FontWeight="Bold" Margin="-1,-1,0,0"/>
			<MenuItem Name="Madbomb122WSButton" Header="Madbomb122's GitHub" Height="24" Width="142" Background="Gold" FontWeight="Bold"/>
			<MenuItem Name="BlackViperWSButton" Header="BlackViper's Website" Height="24" Width="130" Background="#FF3FDA62" FontWeight="Bold"/>
		</Menu>
	</Grid>
</Window>
"@

	[Void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
	$Form = [Windows.Markup.XamlReader]::Load( (New-Object System.Xml.XmlNodeReader $xaml) )
	$xaml.SelectNodes('//*[@Name]').ForEach{Set-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name) -Scope Script}
	$Runspace = [RunSpaceFactory]::CreateRunspace()
	$PowerShell = [PowerShell]::Create()
	$PowerShell.RunSpace = $Runspace
	$Runspace.Open()
	[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null

	[System.Collections.ArrayList]$Script:VarList = Get-Variable 'WPF_*_CB'
	[System.Collections.ArrayList]$Script:CNoteList = Get-Variable 'WPF_CustomNote*'
	$Script:DataGridListBlank = @{}

	$Form.add_closing{
		If(!$RanScript -And [Windows.Forms.Messagebox]::Show('Are you sure you want to exit?','Exit','YesNo') -eq 'No'){ $_.Cancel = $True }
		SaveSetting
		LogEnd
		ShowConsoleWin 5
	}

	$WPF_RunScriptButton.Add_Click{
		SaveSetting
		$Script:RunScript = 1
		$Script:Black_Viper = $WPF_ServiceConfig.SelectedIndex + 1
		If($Black_Viper -eq $BVCount) {
			If(!(Test-Path -LiteralPath $ServiceConfigFile -PathType Leaf) -And $null -ne $ServiceConfigFile) {
				[Windows.Forms.Messagebox]::Show("The File '$ServiceConfigFile' does not exist.",'Error', 'OK') | Out-Null
				$Script:RunScript = 0
			} Else {
				$Script:LoadServiceConfig = 1
				$Script:Black_Viper = 0
			}
		}
		If($RunScript -eq 1) {
			$Script:RanScript = $True
			$WPF_RunScriptButton.IsEnabled = $False
			$WPF_RunScriptButton.Content = 'Run Disabled while changing services.'
			$WPF_TabControl.Items[3].Visibility = 'Visible'
			$WPF_TabControl.Items[3].IsSelected = $True
			If($WPF_CustomBVCB.IsChecked) {
				$Script:LoadServiceConfig = 2
				$WPF_FilterTxt.text = ''
				$Script:csv = $WPF_dataGrid.Items.ForEach{
					$STF = $ServicesTypeFull.IndexOf($_.BVType)
					If(!$_.CheckboxChecked){ $STF *= -1 }
					[PSCustomObject] @{ ServiceName = $_.ServiceName ;StartType = $STF ;Status = $_.SrvState }
				}
			}
			Black_Viper_Set $Black_Viper $All_or_Min
		} Else {
			RunDisableCheck
		}
	}

	[System.Windows.RoutedEventHandler]$DGclickEvent = {
		If($DataGridLCust -and $DGUpdate -and $WPF_dataGrid.SelectedItem) {
			$CurrObj = $WPF_dataGrid.CurrentItem
			If($CurrObj.CurrType -eq $CurrObj.BVType){ $CurrObj.Matches = $True } Else{ $CurrObj.Matches = $False }
			$WPF_dataGrid.ItemsSource = $DataGridListBlank
			$WPF_dataGrid.ItemsSource = $DataGridListCust
		}
		$Script:DGUpdate = $True
	}
	$WPF_dataGrid.AddHandler([System.Windows.Controls.CheckBox]::CheckedEvent,$DGclickEvent)
	$WPF_dataGrid.AddHandler([System.Windows.Controls.CheckBox]::UnCheckedEvent,$DGclickEvent)
	$WPF_dataGrid.Add_PreviewMouseWheel{ $Script:DGUpdate = $False}

	$WPF_LaptopTweaked_CB.Add_Checked{
		If($WPF_ServiceConfig.Items.Count -eq 3) {
			If($WPF_ServiceConfig.SelectedIndex -eq 2){ $tmp = $True } Else{ $tmp = $False }
			$WPF_ServiceConfig.Items.RemoveAt(2)
			[Void] $WPF_ServiceConfig.Items.Add('Tweaked')
			[Void] $WPF_ServiceConfig.Items.Add('Custom Setting *')
			If($tmp){ $WPF_ServiceConfig.SelectedIndex = 3 }
			$Script:LaptopTweaked = 1
			$Script:BVCount++
			HideShowCustomSrvStuff
		}
	}

	$WPF_LaptopTweaked_CB.Add_UnChecked{
		If($WPF_ServiceConfig.Items.Count -eq 4) {
			If($WPF_ServiceConfig.SelectedIndex -eq 2){ $WPF_ServiceConfig.SelectedIndex = 0 }
			$WPF_ServiceConfig.Items.RemoveAt(2)
			$Script:LaptopTweaked = 0
			$Script:BVCount--
			HideShowCustomSrvStuff
		}
	}

	$WPF_ShowDiagButton.Add_Click{
		UpdateSetting
		$WPF_TabControl.Items[4].Visibility = 'Visible'
		$WPF_TabControl.Items[4].IsSelected = $True
		$WPF_DiagnosticOutput.text = ''
		Clear-Host
		TBoxDiag " Diagnostic Information below, will be copied to the clipboard.`n" -C 13
		$Script:DiagString = ''
		TBoxDiag ' ********START********' -C 11
		TBoxDiag ' Diagnostic Output, Some items may be blank' -C 14
		TBoxDiag '' -C 14
		TBoxDiag ' --------Script Info--------' -C 2
		TBoxDiag ' Script Version: ',$Script_Version -C 14,15
		TBoxDiag ' Release Type: ',$Release_Type -C 14,15
		TBoxDiag ' Services Version: ',$ServiceVersion -C 14,15
		TBoxDiag '' -C 14
		TBoxDiag ' --------System Info--------' -C 2
		TBoxDiag ' Window: ',$FullWinEdition -C 14,15
		TBoxDiag ' Bit: ',$OSBit -C 14,15
		TBoxDiag ' Edition SKU#: ',$WinSku -C 14,15
		TBoxDiag ' Build: ',$BuildVer -C 14,15
		TBoxDiag ' Version: ',$Win10Ver -C 14,15
		TBoxDiag ' PC Type: ',$PCType -C 14,15
		TBoxDiag ' Desktop/Laptop: ',$IsLaptop.Substring(1) -C 14,15
		TBoxDiag '' -C 14
		TBoxDiag ' --------Script Requirements--------' -C 2
		TBoxDiag ' Windows 10 - Home or Pro (64-Bit)' -C 14
		TBoxDiag ' Min Version: ',"$MinVer ($MinVerName)" -C 14,15
		TBoxDiag ' Max Version: ',"$MaxVer ($MaxVerName)" -C 14,15
		TBoxDiag '' -C 14
		TBoxDiag ' --------Current Settings--------' 2
		TBoxDiag ' BlackViper: ',$WPF_ServiceConfig.Text -C 14,15
		If($All_or_Min -eq '-full'){ $TmpAoM = 'All' } Else{ $TmpAoM = 'Min' }
		TBoxDiag ' All/Min: ',$TmpAoM -C 14,15
		TBoxDiag ' ToS: ',$AcceptToS -C 14,15
		TBoxDiag ' Automated: ',$Automated -C 14,15
		TBoxDiag ' ScriptVerCheck: ',$ScriptVerCheck -C 14,15
		TBoxDiag ' ServiceVerCheck: ',$ServiceVerCheck -C 14,15
		TBoxDiag ' InternetCheck: ',$InternetCheck -C 14,15
		TBoxDiag ' ShowAlreadySet: ',$ShowAlreadySet -C 14,15
		TBoxDiag ' ShowNonInstalled: ',$ShowNonInstalled -C 14,15
		TBoxDiag ' ShowSkipped: ',$ShowSkipped -C 14,15
		TBoxDiag ' XboxService: ',$XboxService -C 14,15
		TBoxDiag ' StopDisabled: ',$StopDisabled -C 14,15
		TBoxDiag ' ChangeState: ',$ChangeState -C 14,15
		TBoxDiag ' EditionCheck: ',$EditionCheck -C 14,15
		TBoxDiag ' BuildCheck: ',$BuildCheck -C 14,15
		TBoxDiag ' DryRun: ',$DryRun -C 14,15
		TBoxDiag ' ScriptLog: ',$ScriptLog -C 14,15
		TBoxDiag ' LogName: ',$LogName -C 14,15
		TBoxDiag ' LogBeforeAfter: ',$LogBeforeAfter -C 14,15
		TBoxDiag ' DevLog: ',$DevLog -C 14,15
		TBoxDiag ' BackupServiceConfig: ',$BackupServiceConfig -C 14,15
		TBoxDiag ' BackupServiceType: ',$WPF_BackupServiceType.Text -C 14,15
		TBoxDiag ' ShowConsole: ',$ShowConsole -C 14,15
		TBoxDiag ' LaptopTweaked: ',$LaptopTweaked -C 14,15
		TBoxDiag '' -C 14
		TBoxDiag ' --------Misc Info--------' -C 2
		TBoxDiag ' Run Button txt: ',$WPF_RunScriptButton.Content -C 14,15
		TBoxDiag ' Args: ',$PassedArg -C 14,15
		TBoxDiag '' -C 14
		TBoxDiag ' ********END********' -C 11
		$DiagString | Set-Clipboard
		[Windows.Forms.Messagebox]::Show('Diagnostic Information, has been copied to the clipboard.','Notice', 'OK') | Out-Null
	}

	$WPF_ServiceConfig.Add_SelectionChanged{ HideShowCustomSrvStuff ;RunDisableCheck }
	$WPF_EditionConfig.Add_SelectionChanged{ RunDisableCheck }
	$WPF_FilterTxt.Add_TextChanged{ DGFilter }
	$WPF_ShowConsole_CB.Add_Checked{ ShowConsoleWin 5 } #5 = Show
	$WPF_ShowConsole_CB.Add_UnChecked{ ShowConsoleWin 0 } #0 = Hide
	$WPF_BuildCheck_CB.Add_Click{ RunDisableCheck }
	$WPF_EditionCheckCB.Add_Click{ RunDisableCheck }
	$WPF_ScriptLog_CB.Add_Click{ $WPF_LogNameInput.IsEnabled = $WPF_ScriptLog_CB.IsChecked }
	$WPF_ACUcheckboxChecked.Add_Click{ DGUCheckAll $WPF_ACUcheckboxChecked.IsChecked }
	$WPF_CustomBVCB.Add_Click{ CustomBVCBFun $WPF_CustomBVCB.IsChecked }
	$WPF_DevLogCB.Add_Click{ DevLogCBFunction $WPF_DevLogCB.IsChecked }
	$WPF_btnOpenFile.Add_Click{ OpenSaveDiaglog 0 }
	$WPF_SaveCustomSrvButton.Add_Click{ OpenSaveDiaglog 1 }
	$WPF_SaveRegButton.Add_Click{ OpenSaveDiaglog 2 }
	$WPF_ContactButton.Add_Click{ OpenWebsite 'mailto:madbomb122@gmail.com' }
	$WPF_LoadServicesButton.Add_Click{ GenerateServices }
	$WPF_CheckUpdateSerButton.Add_Click{ UpdateCheckNow -Ser }
	$WPF_CheckUpdateSrpButton.Add_Click{ UpdateCheckNow -Srp }
	$WPF_CheckUpdateBothButton.Add_Click{ UpdateCheckNow -Ser -Srp }
	$WPF_BlackViperWSButton.Add_Click{ OpenWebsite 'http://www.blackviper.com/' }
	$WPF_Madbomb122WSButton.Add_Click{ OpenWebsite 'https://GitHub.com/madbomb122/' }
	$WPF_FeedbackButton.Add_Click{ OpenWebsite "$MySite/issues" }
	$WPF_FAQButton.Add_Click{ OpenWebsite "$MySite/blob/master/README.md" }
	$WPF_DonateButton.Add_Click{ ClickedDonate }
	$WPF_CopyrightButton.Add_Click{ [Windows.Forms.Messagebox]::Show($Copyright,'Copyright', 'OK') | Out-Null }
	$WPF_AboutButton.Add_Click{ [Windows.Forms.Messagebox]::Show("This script lets you set Windows 10's services based on Black Viper's Service Configurations, your own Service Configuration (If in a proper format), or a backup of your Service Configurations made by this script.`n`nThis script was created by MadBomb122.",'About', 'OK') | Out-Null }

	$Script:RunScript = 0
	If($All_or_Min -eq '-Full'){ $WPF_RadioAll.IsChecked = $True } Else{ $WPF_RadioMin.IsChecked = $True }

	$WPF_LogNameInput.Text = $LogName
	If($ScriptLog -eq 1){ $WPF_ScriptLog_CB.IsChecked = $True ;$WPF_LogNameInput.IsEnabled = $True }

	If($IsLaptop -eq '-Lap') {
		$WPF_ServiceConfig.Items.RemoveAt(2)
	} Else {
		$WPF_LaptopTweaked_CB.Visibility = 'Hidden'
		$WPF_LaptopTweaked_txt.Visibility = 'Hidden'
	}
	$Script:BVCount = $WPF_ServiceConfig.Items.Count

	$VarList.ForEach{ If($(Get-Variable -Name ($_.Name.Split('_')[1]) -ValueOnly) -eq 1){ $_.Value.IsChecked = $True } Else{ $_.Value.IsChecked = $False } }
	If($EditionCheck -ne 0){ $WPF_EditionCheckCB.IsChecked = $True ;$WPF_EditionConfig.IsEnabled = $True } Else{ $WPF_EditionCheckCB.IsChecked = $False }
	If('Home' -In $WinEdition,$EditionCheck){ $WPF_EditionConfig.SelectedIndex = 0 } Else{ $WPF_EditionConfig.SelectedIndex = 1 }

	$WPF_BackupServiceType.SelectedIndex = $BackupServiceType
	$WPF_ServiceConfig.SelectedIndex = $Black_Viper
	$WPF_LoadFileTxtBox.Text = $ServiceConfigFile
	$WPF_LoadServicesButton.IsEnabled = SetServiceVersion
	$WPF_Script_Ver_Txt.Text = "Script Version: $Script_Version ($Script_Date) -$Release_Type"
	$WPF_Service_Ver_Txt.Text = "Service Version: $ServiceVersion ($ServiceDate)"

	If($Release_Type -ne 'Stable') {
		If($ShowConsole -eq 1){ $WPF_ShowConsole_CB.IsChecked = $True }
		$WPF_ShowConsole_CB.Visibility = 'Hidden'
	} Else {
		If($ShowConsole -eq 0){ ShowConsoleWin 0 }
	}

	$Script:ServiceImport = 1
	HideShowCustomSrvStuff
	RunDisableCheck
	Clear-Host
	DisplayOut 'Displaying GUI Now' -C 14
	DisplayOut "`nTo exit you can close the GUI or PowerShell Window." -C 14

	$Form.ShowDialog() | Out-Null
}

Function CustomBVCBFun([Bool]$C) {
	$WPF_ACUcheckboxChecked.IsEnabled = $C
	$Script:DataGridLCust = $C
	If($C) {
		$WPF_SaveCustomSrvButton.Content = 'Save Selection'
		$WPF_dataGrid.ItemsSource = $DataGridListCust
	} Else {
		$WPF_SaveCustomSrvButton.Content = 'Save Current'
		$WPF_dataGrid.ItemsSource = $DataGridListOrig
	}
	RunDisableCheck
	DGFilter
}

Function DGFilter {
	$Script:DGUpdate = $False
	$TxtFilter = $WPF_FilterTxt.Text
	$Filter = $FilterList[$WPF_FilterType.SelectedIndex]
	If($DataGridLCust){ $TableFilter = $DataGridListCust } Else{ $TableFilter = $DataGridListOrig }
	$WPF_dataGrid.ItemsSource = $TableFilter.Where{ $_.$Filter -Match $TxtFilter }
	$Script:DGUpdate = $True
}

Function RunDisableCheck {
	If($WPF_BuildCheck_CB.IsChecked){ $Script:BuildCheck = 1 } Else{ $Script:BuildCheck = 0 }
	If($WPF_EditionCheckCB.IsChecked) {
		If($WPF_EditionConfig.SelectedIndex -eq 0){ $Script:EditionCheck = 'Home' } Else{ $Script:EditionCheck = 'Pro' }
		$WPF_EditionConfig.IsEnabled = $True
	} Else {
		$Script:EditionCheck = 0
		$WPF_EditionConfig.IsEnabled = $False
	}

	$EBFailCount = 0
	If(!($EditionCheck -In 'Home','Pro' -or $WinSkuList -Contains $WinSku)){ $EBFailCount = 1 }
	If($Win10Ver -NotIn $MinVer..$MaxVer -And $BuildCheck -ne 1){ $EBFailCount += 2 }

	If($EBFailCount -ne 0) {
		$Buttontxt = 'Run Disabled Due to ' + $EBErrLst[$EBFailCount] + ' Check'
		$TmpHead = 'Black Viper'
		$WPF_RunScriptButton.IsEnabled = $False
	} ElseIf(($WPF_ServiceConfig.SelectedIndex+1) -eq $BVCount) {
		$WPF_RunScriptButton.IsEnabled = $False
		$WPF_LoadServicesButton.IsEnabled = $False
		If(!$ServiceConfigFile -or !(Test-Path -LiteralPath $ServiceConfigFile -PathType Leaf)) {
			$Buttontxt = 'Run Disabled, No Custom Service List File Selected or Does not exist.'
		} Else {
			[System.Collections.ArrayList]$Tempcheck = Import-Csv -LiteralPath $ServiceConfigFile
			If($null -In $Tempcheck[0].StartType,$Tempcheck[0].ServiceName) {
				$tmpG = $Tempcheck[0].'Def-Pro-Full'
				If($tmpG -In 'GernetatedByMadBomb122','GeneratedByMadBomb122') {
					$Script:ServiceConfigFile = ''
					$WPF_LoadFileTxtBox.Text = ''
					$Buttontxt = 'Run Disabled, No Custom Service List File Selected or Does not exist.'
					[Windows.Forms.Messagebox]::Show("Please don't load the 'BlackViper.csv' File... `nSelect another 'File' or Select a 'Serivce Configuration' above.",'Error', 'OK') | Out-Null
				} Else {
					$Buttontxt = 'Run Disabled, Invalid Custom Service File.'
				}
			} Else {
				$WPF_RunScriptButton.IsEnabled = $True
				$WPF_LoadServicesButton.IsEnabled = $True
				$Buttontxt = 'Run Script with Custom Service List'
			}
		}
		$TmpHead = 'Custom Service'
	} Else {
		If($WPF_ServiceConfig.SelectedIndex -eq 0){ $TmpHead = 'Win Default' } Else{ $TmpHead = 'Black Viper' }
		If($WPF_CustomBVCB.IsChecked){ $Buttontxt = 'Run Script with Customize Service List' } Else{ $Buttontxt = 'Run Script' }
		$WPF_RunScriptButton.IsEnabled = $True
		$WPF_LoadServicesButton.IsEnabled = $True
	}

	$tmp = $WPF_FilterType.SelectedIndex
	For($i=($WPF_FilterType.Items.Count - 1) ;$i -ge 4 ;$i--){ $WPF_FilterType.Items.RemoveAt($i) }
	[Void] $WPF_FilterType.Items.Add($TmpHead)
	[Void] $WPF_FilterType.Items.Add('State')
	[Void] $WPF_FilterType.Items.Add('Description')
	[Void] $WPF_FilterType.Items.Add('Path')
	$WPF_FilterType.SelectedIndex = $tmp
	$WPF_dataGrid.Columns[4].Header = $TmpHead
	$WPF_RunScriptButton.Content = $Buttontxt
}

Function GenerateServices {
	$Black_Viper = $WPF_ServiceConfig.SelectedIndex + 1
	If($Black_Viper -eq $BVCount) {
		If($Script:ServiceGen -eq 0){ $Script:ServiceImport = 1 }
		$Script:LoadServiceConfig = 1
		$ServiceFilePath = $WPF_LoadFileTxtBox.Text
		$Script:ServiceGen = 1
	} Else {
		If($Script:ServiceGen -eq 1){ $Script:ServiceImport = 1 }
		If($WPF_RadioAll.IsChecked){ $FullMin = '-Full' ;$WPF_ACUcheckboxChecked.IsChecked = $True } Else{ $FullMin = '-Min' ;$WPF_ACUcheckboxChecked.IsChecked = $False }
		$Script:LoadServiceConfig = 0
		$ServiceFilePath = $BVServiceFilePath
		$Script:ServiceGen = 0
	}

	If($LoadServiceConfig -eq 1) {
		$BVS = 'StartType'
		$FullMin = ''
	} ElseIf($Black_Viper -eq 1) {
		$BVS = 'Def-' +$WinEdition
	} ElseIf($Black_Viper -eq 2) {
		$BVS = 'Safe' + $IsLaptop
	} ElseIf($Black_Viper -eq 3) {
		$BVS = 'Tweaked-Desk'
	}
	$BVSAlt = $BVS + '-Full'
	$BVS += $FullMin
	If($WPF_XboxService_CB.IsChecked){ $Script:XboxService = 1 } Else{ $Script:XboxService = 0 }
	If($ServiceImport -eq 1) {
		[System.Collections.ArrayList] $Script:ServCB = Import-Csv -LiteralPath $ServiceFilePath
		$Script:ServiceImport = 0
	}
	[System.Collections.ArrayList]$Script:DataGridListOrig = @{}

	$Script:DataGridListCust = $ServCB.ForEach{
		$ServiceName = QMarkServices $_.ServiceName
		If($CurrServices.Name -Contains $ServiceName) {
			$tmp = ForEach($srv in $CurrServices){ If($srv.Name -eq $ServiceName){ $srv ;Break } }
			$ServiceCommName = $tmp.DisplayName
			$ServiceCurrType = $tmp.StartType
			$SrState = $tmp.Status
			$SrvDescription = $tmp.Description
			$SrvPath = $tmp.PathName
			[Int]$ServiceTypeNum = $_.$BVS
			If($ServiceCurrType -eq 'Disabled') {
				$ServiceCurrType = $ServicesTypeFull[1]
			} ElseIf($ServiceCurrType -eq 'Manual') {
				$ServiceCurrType = $ServicesTypeFull[2]
			} ElseIf($ServiceCurrType -eq 'Auto') {
				If(AutoDelayTest $ServiceName -eq 1){ $ServiceCurrType = $ServicesTypeFull[4] } Else{ $ServiceCurrType = $ServicesTypeFull[3] }
			}
			If($ServiceTypeNum -In -4..0) {
				$checkbox = $False
				If($ServiceTypeNum -eq 0){ $ServiceTypeNum = $_.$BVSAlt } Else{ $ServiceTypeNum *= -1 }
			} ElseIf($XboxService -eq 1 -and $XboxServiceArr -Contains $ServiceName) {
				$checkbox = $False
			} Else {
				$checkbox = $True
			}
			$ServiceType = $ServicesTypeFull[$ServiceTypeNum]
			If($ServiceType -eq  $ServiceCurrType){ $Match = $True } Else{ $Match = $False }
			[PSCustomObject] @{ CheckboxChecked = $checkbox ;CName = $ServiceCommName ;ServiceName = $ServiceName ;CurrType = $ServiceCurrType ;BVType = $ServiceType ;StartType = $ServiceTypeNum ;ServiceTypeListDG = $ServicesTypeFull ;SrvStateListDG = $SrvStateList ;SrvState = $SrState ;SrvDesc = $SrvDescription ;SrvPath = $SrvPath ;Matches = $Match }
			$Script:DataGridListOrig += [PSCustomObject] @{ CheckboxChecked = $checkbox ;CName = $ServiceCommName ;ServiceName = $ServiceName ;CurrType = $ServiceCurrType ;BVType = $ServiceType ;StartType = $ServiceTypeNum ;ServiceTypeListDG = $ServicesTypeFull ;SrvStateListDG = $SrvStateList ;SrvState = $SrState ;SrvDesc = $SrvDescription ;SrvPath = $SrvPath ;Matches = $Match }
		}
	}
	If($WPF_CustomBVCB.IsChecked){ $WPF_dataGrid.ItemsSource = $DataGridListCust } Else{ $WPF_dataGrid.ItemsSource = $DataGridListOrig }

	If(!$ServicesGenerated) {
		$WPF_ServiceClickLabel.Visibility = 'Hidden'
		$WPF_ServiceNote.Visibility = 'Visible'
		$WPF_CustomBVCB.Visibility = 'Visible'
		$WPF_SaveCustomSrvButton.Visibility = 'Visible'
		$WPF_SaveRegButton.Visibility = 'Visible'
		$WPF_TableLegend.Visibility = 'Visible'
		$WPF_Div1.Visibility = 'Visible'
		$WPF_Div2.Visibility = 'Visible'
		$WPF_FilterTxt.Visibility = 'Visible'
		$WPF_FilterType.Visibility = 'Visible'
		$WPF_FilterLabel.Visibility = 'Visible'
		$WPF_LoadServicesButton.Content = 'Reload'
		$Script:ServicesGenerated = $True
	}
}

Function DGUCheckAll([Bool]$C) {
	If($WPF_FilterTxt.Text -ne '') {
		$Script:DGUpdate = $False
		$TxtFilter = $WPF_FilterTxt.Text
		$Filter = $FilterList[$WPF_FilterType.SelectedIndex]
		$TableFilter = $DataGridListCust.Where{ $_.$Filter -Match $TxtFilter }
		$TableFilter.ForEach{ $_.CheckboxChecked = $C }
		$WPF_dataGrid.ItemsSource = $TableFilter
		$Script:DGUpdate = $True
	} Else {
		$DataGridListCust.ForEach{ $_.CheckboxChecked = $C }
	}
	$WPF_dataGrid.Items.Refresh()
}

Function TBoxDiag {
	Param( [Alias('T')] [String[]]$Text, [Alias('C')] [Int[]]$Color )
	$WPF_DiagnosticOutput.Dispatcher.Invoke(
		[action]{
			For($i=0 ;$i -lt $Text.Length ;$i++) {
				$Run = New-Object System.Windows.Documents.Run
				$Run.Foreground = $colorsGUI[($Color[$i])]
				$Run.Text = $Text[$i]
				$WPF_DiagnosticOutput.Inlines.Add($Run)
			}
			$WPF_DiagnosticOutput.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
		},'Normal'
	)
	$Script:DiagString += "$($Text -Join '')`r`n"
	DisplayOut $Text -C $Color
}

##########
# GUI -End
##########
# Update Functions -Start
##########

Function InternetCheck { If($InternetCheck -eq 1 -or (Test-Connection www.GitHub.com -Count 1 -Quiet)){ Return $True } Return $False }

Function UpdateCheckAuto {
	If(InternetCheck) {
		UpdateCheck -NAuto:$False
	} Else {
		$Script:ErrorDi = 'No Internet'
		Error_Top
		DisplayOutLML 'No Internet connection detected or GitHub.com' -C 2 -L
		DisplayOutLML 'is currently down.' -C 2 -L
		DisplayOutLML 'Tested by pinging GitHub.com' -C 2 -L
		MenuBlankLine -L
		DisplayOutLML 'To skip use one of the following methods' -C 2 -L
		DisplayOut '|',' 1. Run Script or bat file with ','-sic',' switch'.PadRight(16),'|' -C 14,2,15,2,14 -L
		DisplayOut '|',' 2. Change ','InternetCheck',' in Script file'.PadRight(28),'|' -C 14,2,15,2,14 -L
		DisplayOut '|',' 3. Change ','InternetCheck',' in bat file'.PadRight(28),'|' -C 14,2,15,2,14 -L
		MenuBlankLine -L
		MenuLine -L
		If(!(Test-Path -LiteralPath $BVServiceFilePath -PathType Leaf)) {
			MenuBlankLine -L
			DisplayOut '|',' The File ','BlackViper.csv',' is missing and the script  ','|' -C 14,2,15,2,14 -L
			DisplayOutLML "can't run w/o it." -C 2 -L
			MenuBlankLine -L
			MenuLine -L
			AutomatedExitCheck 1
		} Else {
			AutomatedExitCheck 0
		}
	}
}

Function UpdateCheckNow {
	If(InternetCheck) {
		UpdateCheck @args
	} Else {
		$Script:ErrorDi = 'No Internet'
		[Windows.Forms.Messagebox]::Show('No Internet connection detected or GitHub is down. If you are connected to the internet, Click the Skip internet checkbox.','Error: No Internet', 'OK','Error') | Out-Null
	}
}

Function UpdateCheck {
	Param (
		[Switch]$NAuto = $True,
		[Alias('Srp')] [Switch]$SrpCheck,
		[Alias('Ser')] [Switch]$SerCheck
	)

	Try {
		$CSV_Ver = Invoke-WebRequest $Version_Url -ErrorAction Stop | ConvertFrom-Csv
		$Message = ''
	} Catch {
		$CSV_Ver = $False
		$Message = 'Error: Unable to check for update, try again later.'
		If($ScriptLog -eq 1){ Write-Output "$(GetTime): $Message" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append}
	}

	If(($SerCheck -or $ServiceVerCheck -eq 1) -and !$CSV_Ver) {
		$WebVersion = $CSV_Ver[1].Version
		If($ServiceVersion -eq 'Missing File'){ $ServVer = '0.0' } Else{ $ServVer = $ServiceVersion }
		If($LoadServiceConfig  -In 0,1 -And $WebVersion -gt $ServVer) {
			$Choice = 'Yes'
			If($NAuto) {
				If($ServiceVersion -eq 'Missing File') {
					$UpdateFound = 'Download Missing BlackViper.csv file?'
					$UpdateTitle = 'Missing File'
				} Else {
					$UpdateFound = "Update Service File from $ServVer to $WebVersion ?"
					$UpdateTitle = 'Update Found'
				}
				$Choice = [Windows.Forms.Messagebox]::Show($UpdateFound,$UpdateTitle,'YesNo')
			}
			If($Choice -eq 'Yes') {
				If($ScriptLog -eq 1){ Write-Output "$(GetTime): Downloading update for 'BlackViper.csv'" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append}
				DownloadFile $Service_Url $BVServiceFilePath
				$Message = "Service File Updated to $WebVersion"
				If($LoadServiceConfig -ne 2){
					[System.Collections.ArrayList]$Script:csv = Import-Csv -LiteralPath $BVServiceFilePath
					SetServiceVersion
				} Else {
					$WPF_Service_Ver_Txt.Text = "Service Version: $WebVersion"
				}
			} ElseIf(!$SrpCheck) {
				$NAuto = $False
			}
		} ElseIf($NAuto) {
			$Message = 'No Service update Found.'
		}
	}
	If(($SrpCheck -or $ScriptVerCheck -eq 1) -and !$CSV_Ver) {
		If($Release_Type -eq 'Stable'){ $CSVLine = 0 ;$RT = '' } Else{ $CSVLine = 2 ;$RT = 'Testing/' }
		$WebScriptVer = $CSV_Ver[$CSVLine].Version + "." + $CSV_Ver[$CSVLine].MinorVersion
		If($WebScriptVer -gt $Script_Version) {
			$Choice = 'Yes'
			If($NAuto){ $Choice = [Windows.Forms.Messagebox]::Show("Update Script File from $Script_Version to $WebScriptVer ?",'Update Found','YesNo') }
			If($Choice -eq 'Yes') {
				$Script:RanScript = $True
				ScriptUpdateFun $RT
			} ElseIf($Message -eq '') {
				$NAuto = $False
			}
		} ElseIf($NAuto) {
			If($Message -eq ''){ $Message = 'No Script update Found.' } Else{ $Message = 'Congrats you have the latest Service and Script version.' }
		}
	}
	If($NAuto){ [Windows.Forms.Messagebox]::Show($Message,'Update','OK') | Out-Null }
}

Function ScriptUpdateFun([String]$RT) {
	SaveSetting
	$Script_Url = $URL_Base + $RT + 'BlackViper-Win10.ps1'
	$ScrpFilePath = $FileBase + 'BlackViper-Win10.ps1'
	$Script:RanScript = $True
	$FullVer = $WebScriptVer + '.' + $WebScriptMinorVer
	$UpArg = ''
	If(!$GuiSwitch) {
		If($LoadServiceConfig -eq 1) {
			$UpArg += "-lcsc $ServiceConfigFile "
		} ElseIf($LoadServiceConfig -eq 2) {
			$TempSrv = $Env:Temp + '\TempSrv.csv' ;$Script:csv | Export-Csv -LiteralPath $TempSrv -Force -Delimiter ',' ;$UpArg += "-lcsc $TempSrv "
		}
	}
	$ArgList.ForEach{
		$TruCount = 0
		If($GuiSwitch -and !$_.Gui){ $TC = -1 } Else{ $tmp = $_.Var.Split('=') ;$Count = $_.Match ;$TC = $Count*2 }
		For($i=0 ;$i -lt $TC ;$i+=2) {
			$var = Get-Variable -Name $tmp[$i] -ValueOnly
			If($var -eq $tmp[$i+1]){ $TruCount++ }
		}
		If($TruCount -eq $Count){ $Script:Uparg += $_.Arg + " "}
	}
	If($ScriptLog -eq 1){ $UpArg += "-logc $LogName " }

	Clear-Host
	MenuLine -L
	MenuBlankLine -L
	DisplayOutLML (''.PadRight(18)+'Update Found!') -C 13 -L
	MenuBlankLine -L
	DisplayOut '|',' Updating from version ',"$Script_Version".PadRight(30),'|' -C 14,15,11,14 -L
	MenuBlankLine -L
	DisplayOut '|',' Downloading version ',"$FullVer".PadRight(31),'|' -C 14,15,11,14 -L
	DisplayOutLML 'Will run after download is complete.' -C 15 -L
	MenuBlankLine -L
	MenuLine -L

	DownloadFile $Script_Url $ScrpFilePath
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$ScrpFilePath`" $UpArg" -Verb RunAs
	CloseExit
}

##########
# Update Functions -End
##########
# Log/Backup Functions -Start
##########

Function ServiceBAfun([String]$ServiceBA) {
	If($LogBeforeAfter -eq 1) {
		$ServiceBAFile = "$FileBase$Env:computername-$ServiceBA.log"
		If($ServiceBA -eq 'Services-Before'){ $CurrServices | Out-File -LiteralPath $ServiceBAFile } Else{ Get-Service | Select-Object DisplayName, Name, StartType, Status | Out-File -LiteralPath $ServiceBAFile }
	} ElseIf($LogBeforeAfter -eq 2) {
		If($ServiceBA -eq 'Services-Before'){ $TMPServices = $CurrServices } Else{ $TMPServices = Get-Service | Select-Object DisplayName, Name, StartType, Status }
		Write-Output "`n$ServiceBA -Start" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output ''.PadRight(37,'-') | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output $TMPServices | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output ''.PadRight(37,'-') | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output "$ServiceBA -End`n" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
	}
}

Function Save_Service([String]$SavePath) {
	If($WPF_CustomBVCB.IsChecked) {
		$SaveService = $WPF_dataGrid.Items.ForEach{
			$STF = $ServicesTypeFull.IndexOf($_.BVType)
			If(!$_.CheckboxChecked){ $STF *= -1 }
			$ServiceName = $_.ServiceName
			If($ServiceName -Like "*$ServiceEnd"){ $ServiceName = $ServiceName -Replace '_.+','_?????' }
			[PSCustomObject] @{ ServiceName = $ServiceName ;StartType = $STF ;Status = $_.SrvState }
		}
	} Else {
		$SaveService = GenerateSaveService
	}
	$SaveService | Export-Csv -LiteralPath $SavePath -Encoding Unicode -Force -Delimiter ','
	[Windows.Forms.Messagebox]::Show("File saved as '$SavePath'",'File Saved', 'OK') | Out-Null
}

Function Save_ServiceBackup {
	$SaveService = @()
	$ServiceSavePath = $FileBase + $Env:computername + '-Service-Backup.csv'
	$SaveService = GenerateSaveService
	$SaveService | Export-Csv -LiteralPath $ServiceSavePath -Encoding Unicode -Force -Delimiter ','
}

Function GenerateSaveService {
	$TMPServiceL = $AllService.ForEach{
		$ServiceName = $_.Name
		If($Skip_Services -NotContains $ServiceName) {
			$tmp = $_.StartType
			If($tmp -eq 'Disabled') {
				$StartType = 1
			} ElseIf($tmp -eq 'Manual') {
				$StartType = 2
			} ElseIf($tmp -eq 'Auto') {
				If(AutoDelayTest $ServiceName -eq 1){ $StartType = 4 } Else{ $StartType = 3 }
			} Else {
				$StartType = $tmp
			}
			If($ServiceName -Like "*$ServiceEnd"){ $ServiceName = $ServiceName -Replace '_.+','_?????' }
			[PSCustomObject] @{ ServiceName = $ServiceName ;StartType = $StartType ;Status = $_.Status }
		}
	}
	Return $TMPServiceL
}

Function RegistryServiceFileBackup {
	$SavePath = $FileBase + $Env:computername + '-Service-Backup.reg'
	If($WPF_CustomBVCB.IsChecked){ GenerateRegistryCustom $SavePath } Else{ GenerateRegistryRegular $SavePath }
}

Function RegistryServiceFile([String]$TempFP) {
	If($WPF_CustomBVCB.IsChecked){ GenerateRegistryCustom $TempFP } Else{ GenerateRegistryRegular $TempFP }
	[Windows.Forms.Messagebox]::Show("Registry File saved as '$TempFP'",'File Saved', 'OK') | Out-Null
}

Function GenerateRegistryRegular([String]$TempFP) {
	Write-Output "Windows Registry Editor Version 5.00`n" | Out-File -LiteralPath $TempFP
	$AllService.ForEach{
		$ServiceName = $_.Name
		If($Skip_Services -NotContains $ServiceName) {
			$tmp = $_.StartType
			If($tmp -eq 'Disabled'){ $ServiceTypeNum = 4 } ElseIf($tmp -eq 'Manual'){ $ServiceTypeNum = 3 } ElseIf($tmp -eq 'Auto' ){ $ServiceTypeNum = 2 }
			$Num = '"Start"=dword:0000000' + $ServiceTypeNum
			Write-Output "[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$ServiceName]" | Out-File -LiteralPath $TempFP -Append
			Write-Output $Num | Out-File -LiteralPath $TempFP -Append
			If($ServiceTypeNum -eq 2 -and (AutoDelayTest $ServiceName -eq 1)){ Write-Output '"DelayedAutostart"=dword:00000001' | Out-File -LiteralPath $TempFP -Append }
			Write-Output '' | Out-File -LiteralPath $TempFP -Append
		}
	}
}

Function GenerateRegistryCustom([String]$TempFP) {
	Write-Output "Windows Registry Editor Version 5.00`n" | Out-File -LiteralPath $TempFP
	$WPF_dataGrid.Items.ForEach{
		If($_.CheckboxChecked) {
			$ServiceName = QMarkServices $_.ServiceName
			$ServiceTypeNum = $ServicesTypeFull.IndexOf($_.BVType)
			If($ServiceTypeNum -ne 0 -And $Skip_Services -NotContains $ServiceName) {
				$Num = '"Start"=dword:0000000' + $ServicesRegTypeList[$ServiceTypeNum]
				Write-Output "[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$ServiceName]" | Out-File -LiteralPath $TempFP -Append
				Write-Output $Num | Out-File -LiteralPath $TempFP -Append
				If($ServiceTypeNum -eq 4){ Write-Output '"DelayedAutostart"=dword:00000001' | Out-File -LiteralPath $TempFP -Append }
				Write-Output '' | Out-File -LiteralPath $TempFP -Append
			}
		}
	}
}

Function DevLogSet {
	$Script:ScriptLog = 1
	$Script:LogName = 'Dev-Log.log'
	$Script:Diagnostic = 1
	$Script:Automated = 0
	$Script:LogBeforeAfter = 2
	$Script:DryRun = 1
	$Script:AcceptToS = 'Accepted'
	$Script:ShowNonInstalled = 1
	$Script:ShowSkipped = 1
	$Script:ShowAlreadySet = 1
}

Function CreateLog {
	If($DevLog -eq 1){ DevLogSet }
	If($ScriptLog -ne 0) {
		$Script:LogFile = $FileBase + $LogName
		$Time = Get-Date -Format 'MM/dd/yyyy hh:mm:ss tt'
		If($ScriptLog -eq 2) {
			Write-Output '$(GetTime): Updated Script File running' | Out-File -LiteralPath $LogFile -Encoding Unicode -NoNewline -Append
			Write-Output "`n--Start of Log ($Time)--" | Out-File -LiteralPath $LogFile -Encoding Unicode -NoNewline -Append
			$ScriptLog = 1
		} Else {
			Write-Output "--Start of Log ($Time)--" | Out-File -LiteralPath $LogFile -Encoding Unicode
		}
	}
	$Script:LogStarted = 1
}

Function DiagnosticCheck([Int]$Bypass) {
	If($Release_Type -ne 'Stable' -or 1 -In $Bypass,$Diagnostic) {
		DisplayOut ' ********START********' -C 11 -L
		DisplayOut ' Diagnostic Output, Some items may be blank' -C 14 -L
		DisplayOut "`n --------Script Info--------" -C 2 -L
		DisplayOut ' Script Version: ',$Script_Version -C 14,15 -L
		DisplayOut ' Release Type: ',$Release_Type -Color 14,15 -L
		If(!(Test-Path -LiteralPath $BVServiceFilePath -PathType Leaf)){ $SrvFileExist = 'Missing' } Else{ $SrvFileExist = 'Exist' }
		DisplayOut ' Service File: ',$SrvFileExist -C 14,15 -L
		DisplayOut "`n --------System Info--------" -C 2 -L
		DisplayOut ' Window: ',$FullWinEdition -C 14,15 -L
		DisplayOut ' Bit: ',$OSBit -C 14,15 -L
		DisplayOut ' Edition SKU#: ',$WinSku -C 14,15 -L
		DisplayOut ' Build: ',$BuildVer -C 14,15 -L
		DisplayOut ' Version: ',$Win10Ver -C 14,15 -L
		DisplayOut ' PC Type: ',$PCType -C 14,15 -L
		DisplayOut ' Desktop/Laptop: ',$IsLaptop.Substring(1) -C 14,15 -L
		DisplayOut "`n --------Script Requirements--------" -C 2 -L
		DisplayOut ' Windows 10 - Home or Pro (64-Bit)' -C 14 -L
		DisplayOut ' Min Version: ',"$MinVer ($MinVerName)" -C 14,15 -L
		DisplayOut ' Max Version: ',"$MaxVer ($MaxVerName)" -C 14,15 -L
		DisplayOut "`n --------Misc Info--------" -C 2 -L
		DisplayOut ' Args: ',$PassedArg -C 14,15 -L
		DisplayOut ' Error: ',$ErrorDi -C 13,15 -L
		DisplayOut "`n --------Settings--------" -C 2 -L
		DisplayOut ' BlackViper: ',$Black_Viper -C 14,15 -L
		If($All_or_Min -eq '-full'){ $TmpAoM = 'All' } Else{ $TmpAoM = 'Min' }
		DisplayOut ' All/Min: ',$TmpAoM -C 14,15 -L
		DisplayOut ' ToS: ',$AcceptToS -C 14,15 -L
		DisplayOut ' Automated: ',$Automated -C 14,15 -L
		DisplayOut ' ScriptVerCheck: ',$ScriptVerCheck -C 14,15 -L
		DisplayOut ' ServiceVerCheck: ',$ServiceVerCheck -C 14,15 -L
		DisplayOut ' InternetCheck: ',$InternetCheck -C 14,15 -L
		DisplayOut ' ShowAlreadySet: ',$ShowAlreadySet -C 14,15 -L
		DisplayOut ' ShowNonInstalled: ',$ShowNonInstalled -C 14,15 -L
		DisplayOut ' ShowSkipped: ',$ShowSkipped -C 14,15 -L
		DisplayOut ' XboxService: ',$XboxService -C 14,15 -L
		DisplayOut ' StopDisabled: ',$StopDisabled -C 14,15 -L
		DisplayOut ' ChangeState: ',$ChangeState -C 14,15 -L
		DisplayOut ' EditionCheck: ',$EditionCheck -C 14,15 -L
		DisplayOut ' BuildCheck: ',$BuildCheck -C 14,15 -L
		DisplayOut ' DryRun: ',$DryRun -C 14,15 -L
		DisplayOut ' ScriptLog: ',$ScriptLog -C 14,15 -L
		DisplayOut ' LogName: ',$LogName -C 14,15 -L
		DisplayOut ' LogBeforeAfter: ',$LogBeforeAfter -C 14,15 -L
		DisplayOut ' DevLog: ',$DevLog -C 14,15 -L
		DisplayOut ' BackupServiceConfig: ',$BackupServiceConfig -C 14,15 -L
		DisplayOut ' BackupServiceType: ',$BackupServiceType -C 14,15 -L
		DisplayOut ' ShowConsole: ',$ShowConsole -C 14,15 -L
		DisplayOut ' LaptopTweaked: ',$LaptopTweaked -C 14,15 -L
		DisplayOut "`n ********END********" -C 11 -L
	}
}

##########
# Log/Backup Functions -End
##########
# Service Change Functions -Start
##########

Function TBoxService {
	[Alias('T')] [String[]]$Text,
	[Alias('C')] [Int[]]$Color,
	$WPF_ServiceListing.Dispatcher.Invoke(
		[action]{
			For($i=0 ;$i -lt $Text.Length ;$i++) {
				$Run = New-Object System.Windows.Documents.Run
				$Run.Foreground = $colorsGUI[($Color[$i])]
				$Run.Text = $Text[$i]
				$WPF_ServiceListing.Inlines.Add($Run)
			}
			$WPF_ServiceListing.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
		},'Normal'
	)
}

Function Black_Viper_Set([Int]$BVOpt,[String]$FullMin) {
	PreScriptCheck
	If($LoadServiceConfig -In 1,2) {
		$ServiceSetOpt = 'StartType' ;$SrvSetting = 'Custom'
	} ElseIf($Black_Viper -eq 1) {
		$ServiceSetOpt = 'Def-' +$WinEdition + $FullMin ;$SrvSetting = 'Default'
	} ElseIf($Black_Viper -eq 2) {
		$ServiceSetOpt = 'Safe' + $IsLaptop + $FullMin ;$SrvSetting = 'Safe'
	} ElseIf($Black_Viper -eq 3) {
		$ServiceSetOpt = 'Tweaked-Desk' + $FullMin ;$SrvSetting = 'Tweaked'
	}
	If($LogBeforeAfter -eq 2){ DiagnosticCheck 1 }
	ServiceBAfun 'Services-Before'
	ServiceSet $ServiceSetOpt $SrvSetting
}

Function ServiceSet([String]$BVService,[String]$BVSet) {
	If($GuiSwitch){ $WPF_ServiceListing.text = '' }
	$BVChanged = 0
	$BVAlready = 0
	$BVSkipped = 0
	$BVStopped = 0
	$BVRunning = 0
	$BVError = 0
	$BVNotInstalled = 0
	If($DryRun -ne 1){ $Txtd = "`n Changing Service Please wait...`n" ;$StopWatch.Start() } Else{ $Txtd = "`n List of Service that would be changed on Non-Dry Run/Dev Log...`n" }
	DisplayOut $Txtd,' Service Setting: ',$BVSet -C 14,14,15 -L -G:$GuiSwitch
	DisplayOut ' Service_Name - Current -> Change_To' -C 14 -L -G:$GuiSwitch
	DisplayOut ''.PadRight(40,'-') -C 14 -L -G:$GuiSwitch
	$csv.ForEach{
		$DispTempT = @()
		$DispTempC = @()
		$ServiceTypeNum = $_.$BVService
		$ServiceType = $ServicesTypeList[$ServiceTypeNum]
		$ServiceName = QMarkServices $_.ServiceName
		$ServiceCommName = SearchSrv $ServiceName 'DisplayName'
		$ServiceCurrType = ServiceCheck $ServiceName $ServiceType
		$State = $_.Status
		If($null -In $ServiceName,$ServiceCurrType) {
			If($ShowNonInstalled -eq 1){ $DispTempT += " No service with name $($_.ServiceName)" ;$DispTempC += 13 }
			$BVNotInstalled++
			$ServiceTypeNum = 9
		} ElseIf($ServiceTypeNum -In -4..0) {
			If($ShowSkipped -eq 1) {
				If($null -ne $ServiceCommName){ $DispTempT += " Skipping $ServiceCommName ($ServiceName)" } Else{ $DispTempT += " Skipping $($_.ServiceName)" }
				$DispTempC += 14
			}
			$ServiceTypeNum = 9
			$BVSkipped++
		} ElseIf($ServiceTypeNum -In 1..4) {
			If($ServicesTypeList -Contains $ServiceCurrType) {
				$DispTemp = " $ServiceCommName ($ServiceName) - $ServiceCurrType -> $ServiceType"
				Try {
					If($DryRun -ne 1) {
						Set-Service $ServiceName -StartupType $ServiceType -ErrorAction Stop
						If($ServiceTypeNum -eq 4){ AutoDelaySet $ServiceName 1 }
					}
					If($ServiceTypeNum -eq 4){ $DispTemp += ' (Delayed)' }
					$DispTempC += 11
					$BVChanged++
				} Catch {
					$DispTemp = "Unable to Change $ServiceCommName ($ServiceName)"
					$DispTempC += 12
					$BVError++
				}
				$DispTempT += $DispTemp
			} ElseIf($ServiceCurrType -eq 'Already') {
				$ADT = AutoDelayTest $ServiceName
				$DispTemp = " $ServiceCommName ($ServiceName) "
				If($ADT -eq 1 -and $ServiceTypeNum -eq 3) {
					$DispTemp += "- $ServiceType (Delayed) -> $ServiceType"
					If($DryRun -ne 1){ AutoDelaySet $ServiceName 0 }
					$DispTempT += $DispTemp
					$DispTempC += 11
					$BVChanged++
				} ElseIf($ADT -eq 0 -and $ServiceTypeNum -eq 4) {
					$DispTemp += "- $ServiceType -> $ServiceType (Delayed)"
					If($DryRun -ne 1){ AutoDelaySet $ServiceName 1 }
					$DispTempT += $DispTemp
					$DispTempC += 11
					$BVChanged++
				} Else {
					If($ShowAlreadySet -eq 1) {
						$DispTemp += "is already $ServiceType"
						If($ServiceTypeNum -eq 4){ $DispTemp += ' (Delayed)' }
						$DispTempT += $DispTemp
						$DispTempC += 15
					}
					$BVAlready++
				}
			} ElseIf($ServiceCurrType -eq 'Xbox') {
				$DispTempT += " $ServiceCommName ($ServiceName) is an Xbox Service and will be skipped"
				$DispTempC += 2
				$ServiceTypeNum = 9
				$BVSkipped++
			} ElseIf($ServiceCurrType -eq 'Denied') {
				If($Release_Type -ne 'Stable'){ $DispTempT += " $ServiceCommName ($ServiceName) can't be changed." ;$DispTempC += 14 ;$BVError++ }
				$ServiceTypeNum = 9
			}
			If($DryRun -ne 1 -And $null -ne $ServiceName -And ($ChangeState -eq 1 -or ($StopDisabled -eq 1 -And $ServiceTypeNum -eq 1))) {
				If($State -eq 'Stopped') {
					If((SearchSrv $ServiceName 'Status') -eq 'Running') {
						Try {
							Stop-Service $ServiceName -ErrorAction Stop
							$DispTempT += ' -Stopping Service'
							$DispTempC += 13
							$BVStopped++
						} Catch {
							$DispTempT += ' -Unable to Stop Service'
							$DispTempC += 12
							$BVError++
						}
					} Else {
						$DispTempT += ' -Already Stopped'
						$DispTempC += 11
					}
				} ElseIf($State -eq 'Running' -And $ChangeState -eq 1) {
					If((SearchSrv $ServiceName 'Status') -eq 'Stopped') {
						Try {
							Start-Service $ServiceName -ErrorAction Stop
							$DispTempT += ' -Starting Service'
							$DispTempC += 11
							$BVRunning++
						} Catch {
							$DispTempT += ' -Unable to Start Service'
							$DispTempC += 12
							$BVError++
						}
					} Else {
						$DispTempT += ' -Already Started'
						$DispTempC += 15
					}
				}
			}
		} Else {
			DisplayOut " Error: $($item.ServiceName) does not have a valid Setting." -C 13 -L -G:$GuiSwitch
			$BVError++
		}
		If($DispTempT.count -ne 0){ DisplayOut $DispTempT -C $DispTempC -L -G:$GuiSwitch }
	}
	DisplayOut ''.PadRight(40,'-') -C 14 -L -G:$GuiSwitch

	If($DryRun -ne 1) {
		$StopWatch.Stop()
		$StopWatchTime = $StopWatch.Elapsed
		$StopWatch.Reset()
		DisplayOut ' Service Changed...' -C 14 -L -G:$GuiSwitch
		DisplayOut ' Elapsed Time: ',$StopWatchTime -C 14,15 -L -G:$GuiSwitch
		If(1 -In $StopDisabled,$ChangeState){ DisplayOut ' Stopped: ',$BVStopped -C 14,15 -L -G:$GuiSwitch }
		If($ChangeState -eq 1){ DisplayOut ' Running: ',$BVRunning -C 14,15 -L -G:$GuiSwitch }
	} Else {
		DisplayOut ' List of Service Done...' -C 14 -L -G:$GuiSwitch
		DisplayOut "`n If not Non-Dry Run/Dev Log " -C 14 -L -G:$GuiSwitch
	}
	DisplayOut ' Changed: ',$BVChanged -C 14,15 -L -G:$GuiSwitch
	DisplayOut ' Already: ',$BVAlready -C 14,15 -L -G:$GuiSwitch
	DisplayOut ' Skipped: ',$BVSkipped -C 14,15 -L -G:$GuiSwitch
	If($ShowNonInstalled -eq 1){ DisplayOut ' Not Installed: ',$BVNotInstalled -C 14,15 -L -G:$GuiSwitch }
	If($BVError -ge 1){ DisplayOut '  Errors: ',$BVError -C 14,15 -L -G:$GuiSwitch }

	If($BackupServiceConfig -eq 1) {
		If($BackupServiceType -eq 1) {
			DisplayOut ' Backup of Services Saved as CSV file in script directory.' -C 14 -L -G:$GuiSwitch
		} ElseIf($BackupServiceType -eq 0) {
			DisplayOut ' Backup of Services Saved as REG file in script directory.' -C 14 -L -G:$GuiSwitch
		} ElseIf($BackupServiceType -eq 2) {
			DisplayOut ' Backup of Services Saved as CSV and REG file in script directory.' -C 14 -L -G:$GuiSwitch
		}
	}
	If($DryRun -ne 1) {
		ThanksDonate
		If($ConsideredDonation -ne 'Yes' -and $GuiSwitch) {
			$Choice = [Windows.Forms.Messagebox]::Show("Thanks for using my script.`nIf you like this script please consider giving me a donation, Min of `$1 from the adjustable Amazon Gift Card.`n`nWould you Consider giving a Donation?",'Thank You','YesNo','Question')
			If($Choice -eq 'Yes'){ ClickedDonate }
		}
	}
	ServiceBAfun 'Services-After'
	If($DevLog -eq 1 -and $Error.Count -gt $ErrCount){ Write-Output $Error | Out-File -LiteralPath $LogFile -Encoding Unicode -Append ;$ErrCount = $Error.Count }
	If($GuiSwitch) {
		GetCurrServices ;RunDisableCheck
		DisplayOut "`n To exit you can close the GUI or PowerShell Window." 14 -G:$GuiSwitch
	} Else {
		AutomatedExitCheck 1
	}
}

Function ServiceCheck([String]$S_Name,[String]$S_Type) {
	If($CurrServices.Name -Contains $S_Name) {
		If($Skip_Services -Contains $S_Name){ Return 'Denied' }
		If($XboxService -eq 1 -and $XboxServiceArr -Contains $S_Name){ Return 'Xbox' }
		$C_Type = SearchSrv $S_Name 'StartType'
		If($S_Type -ne $C_Type) {
			If($S_Name -eq 'lfsvc' -And $C_Type -eq 'disabled' -And (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3')) {
				Remove-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3' -Recurse -Force
			} ElseIf($S_Name -eq 'NetTcpPortSharing' -And $NetTCP -Contains $CurrServices.Name) {
				Return 'Manual'
			}
			Return $C_Type
		}
		Return 'Already'
	}
	Return $null
}

##########
# Service Change Functions -End
##########
# Misc Functions -Start
##########

Function LoadWebCSV([Int]$ErrorChoice) {
	If($ErrorChoice -eq 0) {
		$Script:ErrorDi = 'Missing File BlackViper.csv -LoadCSV' ;$Pick = ' is Missing.'
	} ElseIf($ErrorChoice -eq 1) {
		$Script:ErrorDi = 'Invalid/Corrupt BlackViper.csv' ;$Pick = ' is Invalid or Corrupt.'
	} Else {
		$Script:ErrorDi = 'BlackViper.csv Not Valid for current Update' ;$Pick = ' needs to be Updated.'
	}
	$Invalid = $False
	While($LoadWebCSV -ne 'Out') {
		Error_Top
		DisplayOut '|',' The File ','BlackViper.csv',"$Pick".PadRight(28),'|' -C 14,2,15,2,14 -L
		MenuBlankLine
		DisplayOut '|',' Do you want to download ','BlackViper.csv',' ?           ','|' -C 14,2,15,2,14 -L
		MenuBlankLine
		MenuLine
		$Invalid = ShowInvalid $Invalid
		$LoadWebCSV = Read-Host "`nDownload? (Y)es/(N)o"
		$LoadWebCSV = $LoadWebCSV.ToLower()
		If($LoadWebCSV -In 'y','yes') {
			DownloadFile $Service_Url $BVServiceFilePath ;$LoadWebCSV = 'Out'
		} ElseIf($LoadWebCSV -In 'n','no') {
			DisplayOut 'For manual download save the following File: ' -C 2 -L
			DisplayOut $Service_Url -C 15 -L
		} Else {
			$Invalid = $True
		}
	}
	If($ErrorChoice -In 1..2){ [System.Collections.ArrayList]$Script:csv = Import-Csv -LiteralPath $BVServiceFilePath }
	CheckBVcsv
	Return
}

Function LoadWebCSVGUI {
	ShowConsoleWin 5
	If($ErrorChoice -eq 0) {
		$Script:ErrorDi = 'Missing File BlackViper.csv -LoadCSV' ;$ErrMessage = "The File 'BlackViper.csv' is Missing.`nDo you want to download the file 'BlackViper.csv'?"
	} ElseIf($ErrorChoice -eq 1) {
		$Script:ErrorDi = 'Invalid/Corrupt BlackViper.csv' ;$ErrMessage = "The File 'BlackViper.csv' is Invalid or Corrupt.`nDo you want to download the file 'BlackViper.csv'?"
	} Else {
		$Script:ErrorDi = 'BlackViper.csv Not Valid for current Update' ;$ErrMessage = "The File 'BlackViper.csv' needs to be Updated.`nDo you want to download the file 'BlackViper.csv'?"
	}
	$Choice = [Windows.Forms.Messagebox]::Show($ErrMessage,'Error','YesNo','Error')
	If($Choice -eq 'Yes'){
		DownloadFile $Service_Url $BVServiceFilePath
		If($ErrorChoice -In 1..2){ [System.Collections.ArrayList]$Script:csv = Import-Csv -LiteralPath $BVServiceFilePath }
		CheckBVcsv
	} Else {
		[Windows.Forms.Messagebox]::Show("To get The File 'BlackViper.csv' go to $MySite to save it.`nWithout the file the script won't run",'Information','OK','Information') | Out-Null
		$Form.Close()
		Exit
	}
}

Function PreScriptCheck {
	If($RunScript -eq 0){ CloseExit }
	If($LogStarted -eq 0){ CreateLog }
	$EBCount = 0
	$Script:ErrorDi = ''

	If($EditionCheck -eq 'Home' -or $WinSku -In 98,100,101) {
		$Script:WinEdition = 'Home'
	} ElseIf($EditionCheck -eq 'Pro' -or $WinSku -In 48,49) {
		$Script:WinEdition = 'Pro'
	} Else {
		$Script:ErrorDi = 'Edition'
		$EditionCheck = 'Fail'
		$EBCount++
	}

	If($Win10Ver -NotIn $MinVer..$MaxVer -And $BuildCheck -ne 1) {
		If($EditionCheck -eq 'Fail'){ $Script:ErrorDi += ' & ' }
		$Script:ErrorDi += 'Build'
		$BuildCheck = 'Fail'
		$EBCount++
	}

	If($EBCount -ne 0) {
		$Script:ErrorDi += ' Check Failed'
		$EBCount=0
		Error_Top
		DisplayOutLML " Script won't run due to the following problem(s)" 2 -L
		MenuBlankLine -L
		MenukLine -L
		If($EditionCheck -eq 'Fail') {
			$EBCount++
			MenuBlankLine -L
			DisplayOutLML "$EBCount. Not a valid Windows Edition for this Script." 2 -L
			DisplayOutLML 'Windows 10 Home and Pro Only' 2 -L
			MenuBlankLine -L
			DisplayOut '|',' You are using ',"$FullWinEdition".PadRight(37),'|' -C 14,2,15,14 -L
			DisplayOut '|',' SKU #: ',"$WinSku".PadRight(44),'|' -C 14,2,15,14 -L
			MenuBlankLine -L
			DisplayOutLML 'If you are using Home or Pro...' 2 -L
			DisplayOutLML 'Please contact me or sumbit issue with:' 2 -L
			DisplayOutLML ' 1. The Edition listed above' 2 -L
			DisplayOutLML ' 2. The SKU # listed above' 2 -L
			MenuBlankLine -L
			DisplayOutLML 'To skip use one of the following methods' 2 -L
			DisplayOut '|','  1. Run Script or bat file with ','-secp',' switch'.PadRight(14),'|' -C 14,2,15,2,14 -L
			DisplayOut '|','  2. Run Script or bat file with ','-sech',' switch'.PadRight(14),'|' -C 14,2,15,2,14 -L
			DisplayOut '|','  3. Change ','EditionCheck',' in script file'.PadRight(28),'|' -C 14,2,15,2,14 -L
			DisplayOut '|','  4. Change ','Skip_EditionCheck',' in bat file'.PadRight(23),'|' -C 14,2,15,2,14 -L
			MenuBlankLine -L
			MenuLine -L
		}
		If($BuildCheck -eq 'Fail') {
			$EBCount++
			MenuBlankLine -L
			DisplayOutLML "$EBCount. Not a valid Build for this Script." 2 -L
			DisplayOutLML "Min Version Recommended - Creator's Update (1703)" 2 -L
			DisplayOutLML "Max Version Recommended - $MaxVerName" 2 -L
			MenuBlankLine -L
			DisplayOut '|',' You are using Build: ',"$BuildVer".PadRight(30),'|' -C 14,2,15,14 -L
			DisplayOut '|',' You are using Version: ',"$Win10Ver".PadRight(28),'|' -C 14,2,15,14 -L
			MenuBlankLine -L
			DisplayOutLML 'To skip use one of the following methods' 2 -L
			DisplayOut '|','  1. Run Script or bat file with ','-sbc',' switch'.PadRight(15),'|' -C 14,2,15,2,14 -L
			DisplayOut '|','  2. Change ','BuildCheck',' in script file'.PadRight(30),'|' -C 14,2,15,2,14 -L
			DisplayOut '|','  3. Change ','Skip_BuildCheck',' in bat file'.PadRight(25),'|' -C 14,2,15,2,14 -L
			MenuLine -L
		}
		AutomatedExitCheck 1
	}

	If($BackupServiceConfig -eq 1) {
		If($BackupServiceType -eq 1) {
			Save_ServiceBackup
		} ElseIf($BackupServiceType -eq 0) {
			RegistryServiceFileBackup
		} ElseIf($BackupServiceType -eq 2) {
			Save_ServiceBackup ;RegistryServiceFileBackup
		}
	}
	If($LoadServiceConfig -eq 1) {
		$ServiceFilePath = $ServiceConfigFile
		If(!(Test-Path -LiteralPath $ServiceFilePath -PathType Leaf)) {
			$Script:ErrorDi = 'Missing File $ServiceConfigFile'
			Error_Top
			$SrvConFileLen = $ServiceFilePath.length
			If($SrvConFileLen -gt 42){ $SrvConFileLen = 42 }
			DisplayOut '|',' The File ',$ServiceFilePath,' is missing.'.PadRight(42-$SrvConFileLen),'|' -C 14,2,15,2,14 -L
			Error_Bottom
		}
		$ServiceVerCheck = 0
	} ElseIf($LoadServiceConfig -eq 2) {
		# This is supposed to be EMPTY
	} Else {
		$ServiceFilePath = $BVServiceFilePath
		If(!(Test-Path -LiteralPath $BVServiceFilePath -PathType Leaf)) {
			If($ServiceVerCheck -eq 0) {
				If($ScriptLog -eq 1){ Write-Output "$(GetTime): Missing File 'BlackViper.csv'" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append }
				If($GuiSwitch){ LoadWebCSVGUI 0 } Else{ LoadWebCSV 0 }
			} Else {
				If($ScriptLog -eq 1){ Write-Output "$(GetTime): Downloading Missing File 'BlackViper.csv'" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append }
				DownloadFile $Service_Url $BVServiceFilePath
			}
			$ServiceVerCheck = 0
		}
	}
	If($LoadServiceConfig -ne 2){ [System.Collections.ArrayList]$Script:csv = Import-Csv -LiteralPath $ServiceFilePath }
	If(1 -In $ScriptVerCheck,$ServiceVerCheck){ UpdateCheckAuto }
	If($LoadServiceConfig -NotIn 1,2){ CheckBVcsv ;$csv.RemoveAt(0) }
}

Function CheckBVcsv {
	$GenBy = $csv[0].'Def-Pro-Full'
	If($GenBy -NotIn 'GernetatedByMadBomb122','GeneratedByMadBomb122') {
		If($Automated -ne 1) {
			If($GuiSwitch){ LoadWebCSVGUI 1 } Else{ LoadWebCSV 1 }
		} Else {
			Error_Top
			DisplayOut '|',' The File ','BlackViper.csv',' is Invalid or Corrupt.     ','|' -C 14,2,15,2,14 -L
			Error_Bottom
		}
	} ElseIf(!(Test-Path -LiteralPath $BVServiceFilePath -PathType Leaf)) {
		If($GuiSwitch){
			[Windows.Forms.Messagebox]::Show("The File 'BlackViper.csv' is missing and couldn't be downloaded.`nFor Manual download go to $MySite",'Information', 'OK','Information') | Out-Null
		} Else{
			$Script:ErrorDi = 'Missing File BlackViper.csv'
			Error_Top
			DisplayOut '|',' The File ','BlackViper.csv'," is missing and couldn't    ",'|' -C 14,2,15,2,14 -L
			DisplayOutLML 'be download for some reason.' 2 -L
			Error_Bottom
		}
	}
	If($GuiSwitch){ $WPF_LoadServicesButton.IsEnabled = SetServiceVersion } Else{ SetServiceVersion | Out-Null }
}

Function PassVal([String]$Pass){ Return $PassedArg[$PassedArg.IndexOf($Pass)+1] }
Function GetArgs {
	If($PassedArg -In '-help','-h'){ ShowHelp }
	If($PassedArg -Contains '-copy'){ ShowCopyright ;Exit }
	If($PassedArg -Contains '-lcsc') {
		$Script:BV_ArgUsed = 3
		$Script:LoadServiceConfig = 1
		$tmp = PassVal '-lcsc'
		If(!$tmp.StartsWith('-')) {
			[System.Collections.ArrayList]$Tempcheck = Import-Csv -LiteralPath $tmp
			If($null -In $Tempcheck[0].StartType,$Tempcheck[0].ServiceName) {
				Error_Top
				If($Tempcheck[0].'Def-Pro-Full' -In 'GernetatedByMadBomb122','GeneratedByMadBomb122') {
					DisplayOut '|'," Please don't load '",'BlackViper.csv',"' by using",' -lcsc ',' |' -C 14,2,15,2,15,14 -L
					DisplayOutLML 'Instead use one of the following instead' -C 2 -L
					$InSwitch = '   -Default   -Safe'
					If($IsLaptop -ne '-Lap') { $InSwitch += '   -Tweaked' }
					DisplayOutLML $InSwitch -C 15 -L
					$Script:ErrorDi = "Can't use -lcsc with BlackViper.csv File"
				} Else {
					DisplayOut '|',' The File ',"$tmp".PadRight(41),' |' -C 14,2,15,14 -L
					DisplayOutLML 'is Invalid or Corrupt.' 2 -L
					$Script:ErrorDi = 'Invalid CSV File'
				}
				Error_Bottom
			}
			$Script:ServiceConfigFile = $tmp
		}
	}
	$ArgList.ForEach{
		If($_.Arg -In $PassedArg) {
			$tmp = $_.Var.Split('=')
			$tc = $tmp.count
			For($i=0 ;$i -lt $tc ;$i+=2) {
				$t1 = $tmp[$i+1] ;$t = $tmp[$i]
				If($t1 -eq '-') {
					$tmpV = PassVal $_.Arg
					If(!$tmpV.StartsWith('-')){ $t1 = $tmpV } Else{ $t = $False }
				}
				If($t){ Set-Variable $t $t1 -Scope Script }
			}
		}
	}
	If($PassedArg -Contains '-diagf'){ $Script:Diagnostic = 2 ;$Script:Automated = 0 ;$Script:ErrorDi = 'Forced Diag Output' }
}

Function ShowHelp {
	Clear-Host
	DisplayOut '             List of Switches' -C 13
	DisplayOut ''.PadRight(53,'-') -C 14
	DisplayOut ' Switch ',"Description of Switch`n".PadLeft(31) -C 14,15
	DisplayOut '-- Basic Switches --' -C 2
	DisplayOut '  -atos ','           Accepts ToS' -C 14,15
	DisplayOut '  -auto ','           Implies ','-atos','...Runs the script to be Automated.. Closes on - User Input, Errors, or End of Script' -C 14,15,14,15
	DisplayOut "`n--Service Configuration Switches--" -C 2
	DisplayOut '  -default ','        Runs the script with Services to Default Configuration' -C 14,15
	DisplayOut '  -safe ',"           Runs the script with Services to Black Viper's Safe Configuration" -C 14,15
	DisplayOut '  -tweaked ',"        Runs the script with Services to Black Viper's Tweaked Configuration" -C 14,15
	DisplayOut '  -lcsc ','File.csv ','  Loads Custom Service Configuration, ','File.csv',' = Name of your backup/custom file' -C 14,11,15,11,15
	DisplayOut "`n--Service Choice Switches--" -C 2
	DisplayOut '  -all ','            Every windows services will change' -C 14,15
	DisplayOut '  -min ','            Just the services different from the default to safe/tweaked list' -C 14,15
	DisplayOut '  -sxb ','            Skips changes to all XBox Services' -C 14,15
	DisplayOut "`n--Update Switches--" -C 2
	DisplayOut '  -usc ','            Checks for Update to Script file before running' -C 14,15
	DisplayOut '  -use ','            Checks for Update to Service file before running' -C 14,15
	DisplayOut '  -sic ',"            Skips Internet Check, if you can't ping GitHub.com for some reason" -C 14,15
	DisplayOut "`n--Log Switches--" -C 2
	DisplayOut '  -log ','            Makes a log file named using default name ','Script.log' -C 14,15,11
	DisplayOut '  -log ','File.log ',' Makes a log file named ','File.log' -C 14,11,15,11
	DisplayOut '  -baf ','            Log File of Services Configuration Before and After the script' -C 14,15
	DisplayOut "`n--Backup Service Configuration--" -C 2
	DisplayOut '  -bscc ','           Backup Current Service Configuration, Csv File' -C 14,15
	DisplayOut '  -bscr ','           Backup Current Service Configuration, Reg File' -C 14,15
	DisplayOut '  -bscb ','           Backup Current Service Configuration, Csv and Reg File' -C 14,15
	DisplayOut "`n--Display Switches--" -C 2
	DisplayOut '  -sas  ','           Show Already Set Services' -C 14,15
	DisplayOut '  -snis ','           Show Not Installed Services' -C 14,15
	DisplayOut '  -sss  ','           Show Skipped Services' -C 14,15
	DisplayOut "`n--Misc Switches--" -C 2
	DisplayOut '  -dry  ','           Runs the Script and Shows what services will be changed' -C 14,15
	DisplayOut '  -css  ','           Change State of Service' -C 14,15
	DisplayOut '  -sds  ','           Stop Disabled Service' -C 14,15
	DisplayOut "`n--AT YOUR OWN RISK Switches--" -C 13
	DisplayOut '  -secp ','           Skips Edition Check by Setting Edition as Pro' -C 14,15
	DisplayOut '  -sech ','           Skips Edition Check by Setting Edition as Home' -C 14,15
	DisplayOut '  -sbc  ','           Skips Build Check' -C 14,15
	DisplayOut "`n--Dev Switches--" -C 2
	DisplayOut '  -devl ','           Makes a log file with various Diagnostic information, Nothing is Changed ' -C 14,15
	DisplayOut '  -diag ','           Shows diagnostic information, Stops ','-auto' -C 14,15,14
	DisplayOut '  -diagf ','          Forced diagnostic information, Script does nothing else' -C 14,15
	DisplayOut "`n--Help--" -C 2
	DisplayOut '  -help ','           Shows list of switches, then exits script.. alt ','-h' -C 14,15,14
	DisplayOut '  -copy ','           Shows Copyright/License Information, then exits script' -C 14,15
	AutomatedExitCheck 1
	Exit
}

Function StartScript {
	If(Test-Path -LiteralPath $SettingPath -PathType Leaf) {
		$Tmp = (Import-Clixml -LiteralPath $SettingPath | ConvertTo-Xml).Objects.Object.Property."#text"
		While($Tmp){ $Key, $Val, $Tmp = $Tmp ;Set-Variable $Key $Val -Scope Script }
	}

	If($PCType -eq 1) {
		$Script:IsLaptop = '-Desk'
	} Else {
		$Script:IsLaptop = '-Lap'
		If($LaptopTweaked -ne 1 -and $Black_Viper -ge 2){ $Script:Black_Viper = 0 }
	}

	If($PassedArg.Length -gt 0){ GetArgs }
	GetAllServices

	[System.Collections.ArrayList]$Skip_Services = @(
	"BcastDVRUserService$ServiceEnd",
	"DevicePickerUserSvc$ServiceEnd",
	"DevicesFlowUserSvc$ServiceEnd",
	"PimIndexMaintenanceSvc$ServiceEnd",
	"PrintWorkflowUserSvc$ServiceEnd",
	"UnistoreSvc$ServiceEnd",
	"UserDataSvc$ServiceEnd",
	"WpnUserService$ServiceEnd",
	'AppXSVC',
	'BrokerInfrastructure',
	'ClipSVC',
	'CoreMessagingRegistrar',
	'DcomLaunch',
	'EntAppSvc',
	'gpsvc',
	'LSM',
	'MpsSvc',
	'msiserver',
	'NgcCtnrSvc',
	'NgcSvc',
	'RpcEptMapper',
	'RpcSs',
	'Schedule',
	'SecurityHealthService',
	'sppsvc',
	'StateRepository',
	'SystemEventsBroker',
	'tiledatamodelsvc',
	'WdNisSvc',
	'WinDefend')
	If($Win10Ver -ge 1703){ [Void] $Skip_Services.Add('xbgm') }
	If($Win10Ver -ge 1803){ [Void] $Skip_Services.Add('UsoSvc') }

	If($Diagnostic -In 1,2){ $Script:Automated = 0 }
	If($Diagnostic -eq 2) {
		Clear-Host
		DiagnosticCheck 1
		Exit
	} ElseIf($BV_ArgUsed -eq 1) {
		CreateLog
		Error_Top
		$Script:ErrorDi = 'Tweaked + Laptop (Not supported)'
		If($Automated -eq 1){ DisplayOutLML 'Script is set to Automated and...' 2 -L }
		DisplayOutLML "Laptops can't use Tweaked option." 2 -L
		Error_Bottom
	} ElseIf($BV_ArgUsed -In 2,3) {
		$Script:RunScript = 1
		If($AcceptToS -ne 0) {
			If($LoadServiceConfig -eq 1){ Black_Viper_Set } Else{ Black_Viper_Set $Black_Viper $All_or_Min }
		} Else {
			TOS
		}
	} ElseIf($Automated -eq 1) {
		CreateLog
		$Script:ErrorDi = 'Automated Selected, No Service Selected'
		Error_Top
		DisplayOutLML 'Script is set to Automated and no Service' 2 -L
		DisplayOutLML 'Configuration option was selected.' 2 -L
		Error_Bottom
	} ElseIf($AcceptToS -ne 0) {
		$Script:RunScript = 1
		GuiStart
	} Else {
		TOS
	}
}

##########
# Misc Functions -End
##########
#--------------------------------------------------------------------------
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!                                         !!
# !!           SAFE TO EDIT VALUES           !!
# !!                                         !!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Edit values (Option) to your Choice

# Function = Option
# List of Options

$AcceptToS = 0
# 0 = See ToS
# Anything Else = Accept ToS

$EditionCheck = 0
# 0 = Check if Home or Pro Edition
# 'Pro' = Set Edition as Pro (Needs 's)
# 'Home' = Set Edition as Home (Needs 's)

$BuildCheck = 0
# 0 = Check Build (Creator's Update Minimum)
# 1 = Skips this check

$DryRun = 0
# 0 = Runs script normally
# 1 = Runs script but shows what will be changed

$ShowAlreadySet = 1
# 0 = Don't Show Already set Services
# 1 = Show Already set Services

$ShowNonInstalled = 0
# 0 = Don't Show Services not present
# 1 = Show Services not present

$ShowSkipped = 0
# 0 = Don't Show Skipped Services
# 1 = Show Skipped Services

$XboxService = 0
# 0 = Change Xbox Services
# 1 = Skip Change Xbox Services

$StopDisabled = 0
# 0 = Dont change running status
# 1 = Stop services that are disabled

$ChangeState = 0
# 0 = Dont Change State of service to specified/loaded
# 1 = Change State of service to specified/loaded

#----- Log/Backup Items -----
$ScriptLog = 0
# 0 = Don't make a log file
# 1 = Make a log file
# Will be script's directory named `Script.log` (default)

$LogName = "Script.log"
# Name of log file

$LogBeforeAfter = 0
# 0 = Don't make a file of all the services before and after the script
# 1 = Make a file of all the services before and after the script
# Will be script's directory named '(ComputerName)-Services-Before.log' and '(ComputerName)-Services-Services-After.log'

$BackupServiceConfig = 0
# 0 = Don't backup Your Current Service Configuration before services are changes
# 1 = Backup Your Current Service Configuration before services are changes (Configure type below)

$BackupServiceType = 1
# 0 = '.reg' file that you can change w/o using script
# 1 = '.csv' file type that can be imported into script
# 2 = both the above types
# Will be in script's directory named '(ComputerName)-Service-Backup.(File Type)'

#--- Update Related Items ---
$ScriptVerCheck = 0
# 0 = Skip Check for update of Script File
# 1 = Check for update of Script File
# Note: If found will Auto download and runs that, File name will be 'BlackViper-Win10.ps1'

$ServiceVerCheck = 0
# 0 = Skip Check for update of Service File
# 1 = Check for update of Service File
# Note: If found will Auto download and current settings will be used

$InternetCheck = 0
# 0 = Checks if you have Internet
# 1 = Bypass check if your pings are blocked
# Use if Pings are Blocked or can't ping GitHub.com

#---------- Dev Item --------
$Diagnostic = 0
# 0 = Doesn't show Shows diagnostic information
# 1 = Shows diagnostic information

$DevLog = 0
# 0 = Doesn't make a Dev Log
# 1 = Makes a log files
# Devlog Contains -> Service Change, Before & After for Services, and Diagnostic Info --Runs as Dryrun

$ShowConsole = 0
# 0 = Hides console window (Only on stable release)
# 1 = Shows console window -Forced in Testing release

#--------------------------------------------------------------------------
# Do not change
StartScript
