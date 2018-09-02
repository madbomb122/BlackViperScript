##########
# Win 10 Black Viper Service Configuration Script
#
# Script + Menu(GUI) By
#  Author: Madbomb122
# Website: https://github.com/madbomb122/BlackViperScript/
#
# Black Viper's Service Configurations By
#  Author: Charles "Black Viper" Sparks
# Website: http://www.blackviper.com/
#
$Script_Version = '5.2.3'
$Script_Date = 'Sept-01-2018'
$Release_Type = 'Stable'
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

<#------------------------------------------------------------------------------

Copyright (c) 1999-2017 Charles "Black Viper" Sparks - Services Configuration

--------------------------------------------------------------------------------

The MIT License (MIT) + an added Condition

Copyright (c) 2017 Madbomb122 - Black Viper Service Script

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice(s), this permission notice and ANY original donation
link shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

--------------------------------------------------------------------------------

.Prerequisite to run script
	System: Windows 10 x64 (64-bit) (Can run on x32/32-bit AT YOUR OWN RISK)
	Edition: Home or Pro     (Can run on other Edition AT YOUR OWN RISK)
	Build: Creator's Update  (Can run on other Build AT YOUR OWN RISK)
	Files: This script and 'BlackViper.csv' (Service Configurations)

.DESCRIPTION
	Script that can set services based on Black Viper's Service Configurations
	or your own custom services, or backup services (created by this script)

 AT YOUR OWN RISK YOU CAN
	1. Run the script on x86 (32-bit) w/o changing settings (But shows a warning)
	2. Skip the check for
		A. Home/Pro ($Script:EditionCheck variable bottom of script or use -sec switch)
		B. Creator's Update ($Script:BuildCheck variable bottom of script or use -sbc switch)

.BASIC USAGE
	Run script with powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1
	or Use bat file provided

	Then Use the Gui and Select the desired Choices

.ADVANCED USAGE
	One of the following Methods...
		1. Edit values at bottom of the script then run script
		2. Edit bat file and run
		3. Run the script with one of these arguments/switches (space between multiple)
		4. Run the script and pick options in GUI

-- Basic Switches --
 Switch          Description of Switch
  -atos            Accepts ToS
  -auto            Implies -atos...Runs the script to be Automated.. Closes on - User Input, Errors, or End of Script

--Service Configuration Switches--
 Switch          Description of Switch
  -default         Runs the script with Services to Default Configuration
  -safe            Runs the script with Services to Black Viper's Safe Configuration
  -tweaked         Runs the script with Services to Black Viper's Tweaked Configuration
  -lcsc File.csv   Loads Custom Service Configuration, File.csv = Name of your backup/custom file

--Service Choice Switches--
 Switch          Description of Switch
  -all             Every windows services will change
  -min             Just the services different from the default to safe/tweaked list
  -sxb             Skips changes to all XBox Services

--Update Switches--
 Switch          Description of Switch
  -usc             Checks for Update to Script file before running
  -use             Checks for Update to Service file before running
  -sic             Skips Internet Check, if you can't ping GitHub.com for some reason

--Log Switches--
 Switch          Description of Switch
  -log             Makes a log file Script.log
  -baf             Log File of Services Configuration Before and After the script

--Backup Service Configuration--
 Switch          Description of Switch
  -bscc            Backup Current Service Configuration, Csv File
  -bscr            Backup Current Service Configuration, Reg File
  -bscb            Backup Current Service Configuration, Csv and Reg File

--Misc Switches--
 Switch          Description of Switch
  -dry             Runs the script and shows what services will be changed
  -snis            Show not installed Services
  -sss             Show Skipped Services

--AT YOUR OWN RISK Switches--
 Switch          Description of Switch
  -secp            Skips Edition Check by Setting Edition as Pro
  -sech            Skips Edition Check by Setting Edition as Home
  -sbc             Skips Build Check

--Dev Switches--
 Switch          Description of Switch
  -diag            Shows diagnostic information, Stops -auto
  -diagf           Forced diagnostic information, Script does nothing else

------------------------------------------------------------------------------#>
##########
# Pre-Script -Start
##########

Function AutomatedExitCheck([Int]$ExitBit) {
	If($Automated -ne 1){ Read-Host -Prompt "`nPress Any key to Close..." }
	If($ExitBit -eq 1) {
		If($ScriptLog -eq 1) {
			$Time = Get-Date -Format g
			Write-Output "--End of Log ($Time)--" | Out-File -LiteralPath $LogFile -Encoding Unicode -NoNewline -Append
		}
		If($GuiSwitch){ $Form.Close() } ;Exit
	}
}

$Script:WindowVersion = [Environment]::OSVersion.Version.Major
If($WindowVersion -ne 10) {
	Clear-Host
	Write-Host 'Sorry, this Script supports Windows 10 ONLY.' -ForegroundColor 'cyan' -BackgroundColor 'black'
	AutomatedExitCheck 1
}

If($Release_Type -eq 'Stable'){ $ErrorActionPreference = 'SilentlyContinue' }

$Script:PassedArg = $args
$Script:filebase = $PSScriptRoot + '\'

If(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PassedArg" -Verb RunAs ;Exit
}

$URL_Base = 'https://raw.github.com/madbomb122/BlackViperScript/master/'
$Version_Url = $URL_Base + 'Version/Version.csv'
$Service_Url = $URL_Base + 'BlackViper.csv'

If([System.Environment]::Is64BitProcess){ $OSType = 64 }

Function GetServiceEnd {
	$ServiceEndL = Get-Service '*_*' | Select-Object Name | Foreach-Object { $_.Name.Split('_')[1] }
	ForEach($End in $ServiceEndL){ If($Tmp1 -eq $End){ Return $Tmp1 } Else{ $Tmp1 = $End } }
	Return $ServiceEndL[0]
}
$Script:ServiceEnd = GetServiceEnd

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
$colorsGUI[1] = 'yellow'
$colorsGUI[2] = 'darkmagenta'
$colorsGUI[7] = 'cyan'
$colorsGUI[14] = 'black'
$colorsGUI[15] = 'blue'

$DevLogList = @(
'WPF_ScriptLog_CB',
'WPF_Diagnostic_CB',
'WPF_LogBeforeAfter_CB',
'WPF_DryRun_CB',
'WPF_ShowNonInstalled_CB',
'WPF_ShowAlreadySet_CB')

$ServicesTypeList = @(
'',         #0 -Skip Not Installed
'Disabled', #1
'Manual',   #2
'Automatic',#3 -Automatic
'Automatic')#4 -Automatic (Delayed)

$ServicesTypeFull = @()
$ServicesTypeFull += $ServicesTypeList
$ServicesTypeFull[0] = 'Skip'
$ServicesTypeFull[4] += ' (Delayed)'

$SrvStateList = @('Running','Stopped')

$ServicesRegTypeList = @(
'', #0 -None
'4',#1 -Disable
'3',#2 -Manual
'2',#3 -Automatic
'2')#4 -Automatic (Delayed)

$WinSkuList = @(48,49,98,100,101)
$EBErrLst = @('Edition','Build','Edition & Build')
$XboxServiceArr = @('XblAuthManager','XblGameSave','XboxNetApiSvc','XboxGipSvc','xbgm')
$NetTCP = @('NetMsmqActivator','NetPipeActivator','NetTcpActivator')
$Script:SettingPath = $filebase + 'BVSetting.xml'

$Script:Black_Viper = 0
$Script:Automated = 0
$Script:All_or_Min = '-Min'
$Script:RunScript = 2
$Script:ErrorDi = ''
$Script:LogStarted = 0
$Script:LoadServiceConfig = 0
$Script:RanScript = 0
$Script:LaptopTweaked = 0
$Script:ErrCount = $error.Count
$Script:GuiSwitch = $False
$Script:StopWatch = New-Object System.Diagnostics.Stopwatch

##########
# Pre-Script -End
##########
# Multi Use Functions -Start
##########

Function ThanksDonate {
	DisplayOut "`nThanks for using my script." -C 11
	DisplayOut 'If you like this script please consider giving me a donation.' -C 11
	DisplayOut "`nLink to donation:" -C 15
	DisplayOut 'https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/' -C 2
}

Function GetCurrServices{ $Script:CurrServices = Get-CimInstance Win32_service | Select-Object DisplayName, Name, @{ Name = 'StartType' ;Expression = {$_.StartMode} }, @{ Name = 'Status' ;Expression = {$_.State} } }
Function GetAllServices{ $Script:AllService = $CurrServices | Select-Object Name, StartType }
Function OpenWebsite([String]$Url){ [System.Diagnostics.Process]::Start($Url) }
Function DownloadFile([String]$Url,[String]$FilePath){ (New-Object System.Net.WebClient).DownloadFile($Url, $FilePath) }
Function ShowInvalid([Int]$InvalidA){ If($InvalidA -eq 1){ Write-Host "`nInvalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline } Return 0 }
Function AutoDelaySet([String]$Srv,[Int]$EnDi){ Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\$Srv\" -Name 'DelayedAutostart' -Type DWord -Value $EnDi }

Function AutoDelayTest([String]$Srv) {
	$tmp = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$Srv\").DelayedAutostart
	If($tmp -ne $null){ Return $tmp } Else{ Return 0 }
}

Function DisplayOut {
	Param (
		[Alias ("T")] [String[]]$Text,
		[Alias ("C")] [Int[]]$Color = 14,
		[Alias ("L")] [Switch]$Log,
		[Alias ("G")] [Switch]$Gui
	)
	If($Gui){ TBoxMessage $Text -C $Color }
	For($i=0 ;$i -lt $Text.Length ;$i++){ Write-Host $Text[$i] -ForegroundColor $colors[$Color[$i]] -BackgroundColor 'Black' -NoNewLine } ;Write-Host
	If($Log -and $ScriptLog -eq 1) {
		$TextToFile = $Text -Join ' '
		Write-Output $TextToFile | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
	}
}

$MLine = '|'.PadRight(53,'-') + '|'
$MBLine = '|'.PadRight(53) + '|'

Function MenuLine {
	Param( [Switch]$L )
	DisplayOut $MLine -C 14 -L:$L
}

Function MenuBlankLine {
	Param( [Switch]$L )
	DisplayOut $MBLine -C 14 -L:$L
}

Function DisplayOutLML {
	Param (
		[Alias ("T")] [String[]]$Text,
		[Alias ("C")] [Int[]]$Color = 14,
		[Alias ("L")] [Switch]$Log
	)
	DisplayOut '| ',$Text.PadRight(50),' |' -C 14,$Color,14 -L:$Log
}

Function Error_Top_Display {
	Clear-Host
	DiagnosticCheck 0
	MenuBlankLineLog -L
	DisplayOutLML (''.PadRight(22)+'Error') -C 13 -L
	MenuBlankLineLog -L
	MenuBlankLine -L
}

Function Error_Bottom {
	MenuBlankLine -L
	MenuBlankLineLog -L
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

Function TOSDisplay {
	Clear-Host
	$BorderColor = 14
	If($Release_Type -ne 'Stable') {
		$BorderColor = 15
		TOSLine 15
		DisplayOut '|'.PadRight(22),'Caution!!!'.PadRight(31),'|' -C 15,13,15
		TOSBlankLine 15
		DisplayOut '|','         This script is still being tested.         ','|' -C 15,14,15
		DisplayOut '|'.PadRight(17),'USE AT YOUR OWN RISK.'.PadRight(36),'|' -C 15,14,15
		TOSBlankLine 15
	}
	If($OSType -ne 64) {
		$BorderColor = 15
		TOSLine 15
		DisplayOut '|'.PadRight(22),'WARNING!!!'.PadRight(31),'|' -C 15,13,15
		TOSBlankLine 15
		DisplayOut '|','        These settings are ment for x64 Bit.        ','|' -C 15,14,15
		DisplayOut '|'.PadRight(16),'USE AT YOUR OWN RISK.'.PadRight(37),'|' -C 15,14,15
		TOSBlankLine 15
	}
	TOSLine $BorderColor
	DisplayOut '|'.PadRight(21),'Terms of Use'.PadRight(32),'|' -C $BorderColor,11,$BorderColor
	TOSLine $BorderColor
	TOSBlankLine $BorderColor
	DisplayOut '|',' This program comes with ABSOLUTELY NO WARRANTY.    ','|' -C $BorderColor,2,$BorderColor
	DisplayOut '|',' This is free software, and you are welcome to      ','|' -C $BorderColor,2,$BorderColor
	DisplayOut '|',' redistribute it under certain conditions.'.PadRight(52),'|' -C $BorderColor,2,$BorderColor
	TOSBlankLine $BorderColor
	DisplayOut '|',' Read License file for full Terms.'.PadRight(52),'|' -C $BorderColor,2,$BorderColor
	TOSBlankLine $BorderColor
	TOSLine $BorderColor
}

Function TOS {
	While($TOS -ne 'Out') {
		TOSDisplay
		$Invalid = ShowInvalid $Invalid
		$TOS = Read-Host "`nDo you Accept? (Y)es/(N)o"
		$TOS = $TOS.ToLower()
		If($TOS -In 'n','no'){
			Exit
		} ElseIf($TOS -In 'y','yes'){
			$TOS = 'Out'
			$Script:AcceptToS = 'Accepted'
			$Script:RunScript = 1
			If($LoadServiceConfig -eq 1){ Black_Viper_Set } ElseIf($Black_Viper -eq 0){ GuiStart } Else{ Black_Viper_Set $Black_Viper $All_or_Min }
		} Else{
			$Invalid = 1
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
	$SOFileDialog.InitialDirectory = $filebase
	If($SorO -ne 2){ $SOFileDialog.Filter = "CSV (*.csv)| *.csv" } Else{ $SOFileDialog.Filter = "Registration File (*.reg)| *.reg" }
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
	ForEach($Var In $CNoteList){ $Var.Value.Visibility = $Vis }
	$WPF_LoadFileTxtBox.Visibility = $Vis
	$WPF_btnOpenFile.Visibility = $Vis
}

Function SetServiceVersion {
	$TPath = $filebase + 'BlackViper.csv'
	If(Test-Path -LiteralPath $TPath -PathType Leaf) {
		$TMP = Import-Csv -LiteralPath $TPath
		$Script:ServiceVersion = $TMP[0].'Def-Home-Full'
		$Script:ServiceDate = $TMP[0].'Def-Home-Min'
		Return $True
	}
	$Script:ServiceVersion = 'Missing File'
	$Script:ServiceDate = 'BlackViper.csv'
	Return $False
}

Function ClickedDonate{ OpenWebsite 'https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/' ;$Script:ConsideredDonation = 'Yes' }

Function UpdateSetting {
	ForEach($Var In $VarList) {
		If($Var.Value.IsChecked){ $SetValue = 1 } Else{ $SetValue = 0 }
		Set-Variable -Name ($Var.Name.Split('_')[1]) -Value $SetValue -Scope Script
	}
	If($WPF_RadioAll.IsChecked){ $Script:All_or_Min = '-Full' } Else{ $Script:All_or_Min = '-Min' }
	If($WPF_EditionCheckCB.IsChecked){ $Script:EditionCheck = $WPF_EditionConfig.Text }
	$Script:LogName = $WPF_LogNameInput.Text
	$Script:BackupServiceType = $WPF_BackupServiceType.SelectedIndex
}

Function SaveSetting {
	UpdateSetting

	$Black_Viper = $WPF_ServiceConfig.SelectedIndex
	If($Black_Viper -eq 3){ $Black_Viper = 0 }
	If($IsLaptop -eq '-Lap') {
		If($LaptopTweaked -ne 1 -and $Black_Viper -ge 2){ $Script:Black_Viper = 0 }
	}

	[System.Collections.ArrayList]$Settings = @{}
	$Settings += [PSCustomObject] @{ Var = 'AcceptToS' ;Val = $AcceptToS }
	$Settings += [PSCustomObject] @{ Var = 'BackupServiceConfig' ;Val = $BackupServiceConfig }
	$Settings += [PSCustomObject] @{ Var = 'BackupServiceType' ;Val = $BackupServiceType }
	$Settings += [PSCustomObject] @{ Var = 'ScriptVerCheck' ;Val = $ScriptVerCheck }
	$Settings += [PSCustomObject] @{ Var = 'BatUpdateScriptFileName' ;Val = $BatUpdateScriptFileName }
	$Settings += [PSCustomObject] @{ Var = 'ServiceVerCheck' ;Val = $ServiceVerCheck }
	$Settings += [PSCustomObject] @{ Var = 'InternetCheck' ;Val = $InternetCheck }
	$Settings += [PSCustomObject] @{ Var = 'EditionCheck' ;Val = $EditionCheck }
	$Settings += [PSCustomObject] @{ Var = 'BuildCheck' ;Val = $BuildCheck }
	$Settings += [PSCustomObject] @{ Var = 'ShowConsole' ;Val = $ShowConsole }
	$Settings += [PSCustomObject] @{ Var = 'XboxService' ;Val = $XboxService }
	$Settings += [PSCustomObject] @{ Var = 'StopDisabled' ;Val = $StopDisabled }
	$Settings += [PSCustomObject] @{ Var = 'All_or_Min' ;Val = $All_or_Min }
	$Settings += [PSCustomObject] @{ Var = 'Black_Viper' ;Val = $Black_Viper }
	$Settings += [PSCustomObject] @{ Var = 'LaptopTweaked' ;Val = $LaptopTweaked }
	If($ConsideredDonation -eq 'Yes'){ $Settings += [PSCustomObject] @{ Var = 'ConsideredDonation' ;Val='Yes' } }
	If($WPF_DevLogCB.IsChecked) {
		$Settings += [PSCustomObject] @{ Var = 'ScriptLog' ;Val = $Script_Log }
		$Settings += [PSCustomObject] @{ Var = 'LogName' ;Val = $Log_Name }
		$Settings += [PSCustomObject] @{ Var = 'Diagnostic' ;Val = $Diagn_ostic }
		$Settings += [PSCustomObject] @{ Var = 'LogBeforeAfter' ;Val = $Log_Before_After }
		$Settings += [PSCustomObject] @{ Var = 'DryRun' ;Val = $Dry_Run }
		$Settings += [PSCustomObject] @{ Var = 'ShowNonInstalled' ;Val = $Show_Non_Installed }
		$Settings += [PSCustomObject] @{ Var = 'ShowAlreadySet' ;Val = $Show_Already_Set }
	} Else {
		$Settings += [PSCustomObject] @{ Var = 'ScriptLog' ;Val = $ScriptLog }
		$Settings += [PSCustomObject] @{ Var = 'LogName' ;Val = $LogName }
		$Settings += [PSCustomObject] @{ Var = 'Diagnostic' ;Val = $Diagnostic }
		$Settings += [PSCustomObject] @{ Var = 'LogBeforeAfter' ;Val = $LogBeforeAfter }
		$Settings += [PSCustomObject] @{ Var = 'DryRun' ;Val = $DryRun }
		$Settings += [PSCustomObject] @{ Var = 'ShowNonInstalled' ;Val = $ShowNonInstalled }
		$Settings += [PSCustomObject] @{ Var = 'ShowAlreadySet' ;Val = $ShowAlreadySet }
	}
	$Settings | Export-Clixml -LiteralPath $SettingPath
}

Function ShowConsoleWin([Int]$Choice){ [Console.Window]::ShowWindow($ConsolePtr, $Choice) }#0 = Hide, 5 = Show

Function DevLogCBFunction {
	Param( [Switch]$C )
	If(!$C) {
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
	} Else {
		$Script:ScriptLog = $Script_Log
		$Script:LogName = $Log_Name
		$Script:Diagnostic = $Diagn_ostic
		$Script:Automated = $Auto_mated
		$Script:LogBeforeAfter = $Log_Before_After
		$Script:DryRun = $Dry_Run
		$Script:ShowNonInstalled = $Show_Non_Installed
		$Script:ShowSkipped = $Show_Skipped
		$Script:ShowAlreadySet = $Show_Already_Set
	}

	ForEach($Var In $DevLogList) {
		$TmpWPF = Get-Variable -Name $Var -ValueOnly
		If((Get-Variable -Name ($Var.Split('_')[1]) -ValueOnly) -eq 0) {
			$TmpWPF.IsChecked = $False
		} Else {
			$TmpWPF.IsChecked = $True
		}
		$TmpWPF.IsEnabled = $C
	}
	If($ScriptLog -eq 0 -or !$C){ $WPF_LogNameInput.IsEnabled = $False } Else{ $WPF_LogNameInput.IsEnabled = $True }
	$WPF_LogNameInput.Text = $LogName
}

Function GuiStart {
	#Needed to Hide Console window
	Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow() ;[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
	$Script:ConsolePtr = [Console.Window]::GetConsoleWindow()

	Clear-Host
	DisplayOut 'Preparing GUI, Please wait...' -C 15
	$Script:GuiSwitch = $True

[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Black Viper Service Configuration Script By: MadBomb122" Height="375" Width="669" BorderBrush="Black" Background="White">
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
					<DataGrid Name="dataGrid" FrozenColumnCount="2" AutoGenerateColumns="False" AlternationCount="2" HeadersVisibility="Column" Margin="-2,47,-2,-2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">
						<DataGrid.RowStyle>
							<Style TargetType="{x:Type DataGridRow}">
								<Style.Triggers>
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
								</Style.Triggers>
							</Style>
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
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="-2,46,-2,0" Stroke="Black" VerticalAlignment="Top"/>
					<Label Name="ServiceClickLabel" Content="&lt;-- Click to load Service List" HorizontalAlignment="Left" Margin="75,-3,0,0" VerticalAlignment="Top"/>
					<Button Name="LoadServicesButton" Content="Load Services" HorizontalAlignment="Left" Margin="2,1,0,0" VerticalAlignment="Top" Width="76"/>
					<Button Name="SaveCustomSrvButton" Content="Save Current" HorizontalAlignment="Left" Margin="81,1,0,0" VerticalAlignment="Top" Width="80" Visibility="Hidden"/>
					<Button Name="SaveRegButton" Content="Save Registry" HorizontalAlignment="Left" Margin="164,1,0,0" VerticalAlignment="Top" Width="80" Visibility="Hidden"/>
					<Label Name="ServiceNote" Content="Uncheck what you &quot;Don't want to be changed&quot;" HorizontalAlignment="Left" Margin="-2,23,0,0" VerticalAlignment="Top" Visibility="Hidden"/>
					<CheckBox Name="CustomBVCB" Content="Customize Service" HorizontalAlignment="Left" Margin="248,4,0,0" VerticalAlignment="Top" Width="119" RenderTransformOrigin="0.696,0.4" Visibility="Hidden"/>
					<TextBlock Name="TableLegend" HorizontalAlignment="Left" Margin="373,0,-2,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="275" Height="46" FontWeight="Bold" Visibility="Hidden"><Run Background="LightGreen" Text=" Checked &amp; Service is Same as Current                  "/><LineBreak/><Run Background="LightCoral" Text=" Checked &amp; Service is NOT Same as Current          "/><LineBreak/><Run Background="#FFFFFF64" Text=" NOT Checked &amp; Service is NOT Same as Current "/></TextBlock>
					<Rectangle Name="Div1" Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="372,-2,0,0" Stroke="Black" Width="1" Height="48" VerticalAlignment="Top" Visibility="Hidden"/>
				</Grid>
			</TabItem>
			<TabItem Name="Options_tab" Header="Script Options" Margin="-2,0,2,0">
				<Grid Background="#FFE5E5E5">
					<Label Content="Display Options" HorizontalAlignment="Left" Margin="2,-2,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
					<Label Content="Log Options" HorizontalAlignment="Left" Margin="178,-2,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
					<Label Content="Misc Options" HorizontalAlignment="Left" Margin="2,55,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
					<CheckBox Name="Dryrun_CB" Content="Dryrun -Shows what will be changed" HorizontalAlignment="Left" Margin="7,78,0,0" VerticalAlignment="Top" Height="15" Width="213"/>
					<CheckBox Name="LogBeforeAfter_CB" Content="Services Before and After" HorizontalAlignment="Left" Margin="183,21,0,0" VerticalAlignment="Top" Height="16" Width="158"/>
					<CheckBox Name="ShowAlreadySet_CB" Content="Show Already Set Services" HorizontalAlignment="Left" Margin="7,21,0,0" VerticalAlignment="Top" Height="15" Width="158" IsChecked="True"/>
					<CheckBox Name="ShowNonInstalled_CB" Content="Show Not Installed Services" HorizontalAlignment="Left" Margin="7,36,0,0" VerticalAlignment="Top" Height="15" Width="166"/>
					<CheckBox Name="ScriptLog_CB" Content="Script Log:" HorizontalAlignment="Left" Margin="183,36,0,0" VerticalAlignment="Top" Height="18" Width="76"/>
					<CheckBox Name="XboxService_CB" Content="Skip All Xbox Services" HorizontalAlignment="Left" Margin="7,93,0,0" VerticalAlignment="Top" Height="15" Width="137"/>
					<CheckBox Name="BackupServiceConfig_CB" Content="Backup Current Service as:" HorizontalAlignment="Left" Margin="7,123,0,0" VerticalAlignment="Top" Height="15" Width="162"/>
					<ComboBox Name="BackupServiceType" HorizontalAlignment="Left" Margin="169,119,0,0" VerticalAlignment="Top" Width="52" Height="23">
						<ComboBoxItem Content=".reg" HorizontalAlignment="Left" Width="50"/>
						<ComboBoxItem Content=".csv" HorizontalAlignment="Left" Width="50" IsSelected="True"/>
						<ComboBoxItem Content="Both" HorizontalAlignment="Left" Width="50"/>
					</ComboBox>
					<TextBox Name="LogNameInput" HorizontalAlignment="Left" Height="20" Margin="261,34,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="137" IsEnabled="False"/>
					<CheckBox Name="ScriptVerCheck_CB" Content="Auto Script Update*" HorizontalAlignment="Left" Margin="239,95,0,0" VerticalAlignment="Top" Height="15" Width="126"/>
					<CheckBox Name="ServiceVerCheck_CB" Content="Auto Service Update" HorizontalAlignment="Left" Margin="239,80,0,0" VerticalAlignment="Top" Height="15" Width="131"/>
					<CheckBox Name="BatUpdateScriptFileName_CB" Content="Update Bat file with new Script file**" HorizontalAlignment="Left" Margin="239,110,0,0" VerticalAlignment="Top" Height="15" Width="214"/>
					<Button Name="CheckUpdateSerButton" Content="Services" HorizontalAlignment="Left" Margin="494,84,0,0" VerticalAlignment="Top" Width="109"/>
					<Button Name="CheckUpdateSrpButton" Content="Script*" HorizontalAlignment="Left" Margin="494,109,0,0" VerticalAlignment="Top" Width="109"/>
					<Button Name="CheckUpdateBothButton" Content="Services &amp; Script*" HorizontalAlignment="Left" Margin="494,134,0,0" VerticalAlignment="Top" Width="109"/>
					<CheckBox Name="InternetCheck_CB" Content="Skip Internet Check" HorizontalAlignment="Left" Margin="239,125,0,0" VerticalAlignment="Top" Height="15" Width="124"/>
					<Label Content="*Will run and use current settings&#xA;**If update.bat isnt avilable&#xD;&#xA;--Update checks happen before &#xD;&#xA;	services are changed." HorizontalAlignment="Left" Margin="233,134,0,0" VerticalAlignment="Top" FontWeight="Bold" Width="220"/>
					<Label Content="Update Items" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="234,55,0,0" FontWeight="Bold"/>
					<CheckBox Name="BuildCheck_CB" Content="Skip Build Check" HorizontalAlignment="Left" Margin="409,21,0,0" VerticalAlignment="Top" Height="15" Width="110"/>
					<CheckBox Name="EditionCheckCB" Content="Skip Edition Check Set as :" HorizontalAlignment="Left" Margin="409,36,0,0" VerticalAlignment="Top" Height="15" Width="160"/>
					<ComboBox Name="EditionConfig" HorizontalAlignment="Left" Margin="569,33,0,0" VerticalAlignment="Top" Width="60" Height="23">
						<ComboBoxItem Content="Home" HorizontalAlignment="Left" Width="58"/>
						<ComboBoxItem Content="Pro" HorizontalAlignment="Left" Width="58" IsSelected="True"/>
					</ComboBox>
					<CheckBox Name="Diagnostic_CB" Content="Diagnostic Output (On Error)" HorizontalAlignment="Left" Margin="7,169,0,0" VerticalAlignment="Top" Height="15" Width="174"/>
					<CheckBox Name="DevLogCB" Content="Dev Log" HorizontalAlignment="Left" Margin="7,184,0,0" VerticalAlignment="Top" Height="15" Width="174"/>
					<Label Content="SKIP CHECK AT YOUR OWN RISK!" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="409,-2,0,0" FontWeight="Bold"/>
					<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="176,0,0,0" Stroke="Black" Width="1" Height="58" VerticalAlignment="Top"/>
					<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="403,0,0,0" Stroke="Black" Width="1" Height="58" VerticalAlignment="Top"/>
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="-6,58,0,0" Stroke="Black" VerticalAlignment="Top"/>
					<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="229,59,0,0" Stroke="Black" Width="1"/>
					<Label Content="Dev Options" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="2,145,0,0" FontWeight="Bold"/>
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="-6,148,0,0" Stroke="Black" VerticalAlignment="Top" HorizontalAlignment="Left" Width="235"/>
					<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="459,59,0,0" Stroke="Black" Width="1" Height="159" VerticalAlignment="Top"/>
					<Label Content="Check for Update Now for:" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="464,55,0,0" FontWeight="Bold"/>
					<CheckBox Name="ShowConsole_CB" Content="Show Console Window" HorizontalAlignment="Left" Margin="7,199,0,0" VerticalAlignment="Top" Height="15" Width="144"/>
					<Label Content="*Wont remember Settings in&#xD;&#xA;'Service Options' or 'Services&#xD;&#xA;List' Tab" HorizontalAlignment="Left" Margin="464,157,0,0" VerticalAlignment="Top" FontWeight="Bold" Width="177" Height="61"/>
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="230,218,0,0" Stroke="Black" VerticalAlignment="Top"/>
					<CheckBox Name="LaptopTweaked_CB" Content="Enable Tweak Setting on Laptop**" HorizontalAlignment="Left" Margin="235,221,0,0" VerticalAlignment="Top" Height="15" Width="204"/>
					<Label Name="LaptopTweaked_txt" Content="**CAUTION: Use this with EXTREME CAUTION" HorizontalAlignment="Left" Margin="238,230,0,-4" VerticalAlignment="Top" FontWeight="Bold" Width="268"/>
					<CheckBox Name="StopDisabled_CB" Content="Stop Disabled Services" HorizontalAlignment="Left" Margin="7,108,0,0" VerticalAlignment="Top" Height="15" Width="144"/>
					<Button Name="ShowDiagButton" Content="Show Diagnostic" HorizontalAlignment="Left" Margin="7,218,0,0" VerticalAlignment="Top" Width="101" Background="#FF98D5FF"/>
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

	[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
	$Form = [Windows.Markup.XamlReader]::Load( (New-Object System.Xml.XmlNodeReader $xaml) )
	$xaml.SelectNodes("//*[@Name]") | ForEach-Object{Set-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name) -Scope Script}

	$Runspace = [runspacefactory]::CreateRunspace()
	$PowerShell = [PowerShell]::Create()
	$PowerShell.RunSpace = $Runspace
	$Runspace.Open()
	[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') | Out-Null
	[System.Collections.ArrayList]$VarList = Get-Variable 'WPF_*_CB'
	[System.Collections.ArrayList]$CNoteList = Get-Variable 'WPF_CustomNote*'
	[System.Collections.ArrayList]$Script:DataGridListBlank = @{}

	$Form.add_closing({
		If($RanScript -ne 1) {
			If([windows.forms.messagebox]::show('Are you sure you want to exit?','Exit','YesNo') -eq 'No'){ $_.cancel = $True }
		}
		SaveSetting
	})

	$WPF_RunScriptButton.Add_Click({
		SaveSetting
		$Script:RunScript = 1
		$Black_Viper = $WPF_ServiceConfig.SelectedIndex + 1
		If($Black_Viper -eq $BVCount) {
			If(!(Test-Path -LiteralPath $ServiceConfigFile -PathType Leaf) -And $ServiceConfigFile -ne $null) {
				[Windows.Forms.MessageBox]::Show("The File '$ServiceConfigFile' does not exist",'Error', 'OK') | Out-Null
				$Script:RunScript = 0
			} Else {
				$Script:LoadServiceConfig = 1
				$Script:Black_Viper = 0
			}
		}
		If($RunScript -eq 1) {
			$Script:RanScript = 1
			$WPF_RunScriptButton.IsEnabled = $False
			$WPF_RunScriptButton.Content = 'Run Disabled while changing services.'
			$WPF_TabControl.Items[3].Visibility = 'Visible'
			$WPF_TabControl.Items[3].IsSelected = $True
			If($WPF_CustomBVCB.IsChecked) {
				$Script:LoadServiceConfig = 2
				[System.Collections.ArrayList]$Script:csvTemp = @()
				$ServiceCBList = $WPF_dataGrid.Items.Where({$_.CheckboxChecked -eq $True})
				ForEach($item In $ServiceCBList){
					$BVTypeS = BVTypeNameToNumb $item.BVType
					$Script:csvTemp += [PSCustomObject] @{ ServiceName = $item.ServiceName ;StartType = $BVTypeS ;SrvState = $item.SrvState }
				}
				[System.Collections.ArrayList]$Script:csv = $Script:csvTemp
			}
#			$Form.Close()
			Black_Viper_Set $Black_Viper $All_or_Min
		} Else{
			RunDisableCheck
		}
	})

	$WPF_dataGrid.Add_PreviewMouseWheel({ $MouseScroll = $True })

	[System.Windows.RoutedEventHandler]$DGclickEvent = {
		If($WPF_CustomBVCB.Checked -and !$MouseScroll -and $WPF_dataGrid.SelectedItem) {
			$CurrObj = $WPF_dataGrid.CurrentItem
			If($CurrObj.CurrType -eq $CurrObj.BVType){ $CurrObj.Matches = $True } Else{ $CurrObj.Matches = $False }
			$WPF_dataGrid.ItemsSource = $DataGridListBlank
			$WPF_dataGrid.ItemsSource = $DataGridListCust
		}
		$MouseScroll = $False
	}
	$WPF_dataGrid.AddHandler([System.Windows.Controls.CheckBox]::CheckedEvent,$DGclickEvent)
	$WPF_dataGrid.AddHandler([System.Windows.Controls.CheckBox]::UnCheckedEvent,$DGclickEvent)

	$WPF_ServiceConfig.add_SelectionChanged({ HideShowCustomSrvStuff ;RunDisableCheck })
	$WPF_EditionConfig.add_SelectionChanged({ RunDisableCheck })
	$WPF_BuildCheck_CB.Add_Click({ RunDisableCheck })
	$WPF_EditionCheckCB.Add_Click({ RunDisableCheck })

	$WPF_LaptopTweaked_CB.Add_Checked({
		If($WPF_ServiceConfig.Items.Count -eq 3) {
			If($WPF_ServiceConfig.SelectedIndex -eq 2){ $tmp = $True } Else{ $tmp = $False }
			$WPF_ServiceConfig.Items.RemoveAt(2)
			$WPF_ServiceConfig.Items.Add('Tweaked')
			$WPF_ServiceConfig.Items.Add('Custom Setting *')
			If($tmp){ $WPF_ServiceConfig.SelectedIndex = 3 }
			$Script:LaptopTweaked = 1
			$Script:BVCount++
			HideShowCustomSrvStuff
		}
	})

	$WPF_LaptopTweaked_CB.Add_UnChecked({
		If($WPF_ServiceConfig.Items.Count -eq 4) {
			If($WPF_ServiceConfig.SelectedIndex -eq 2){ $WPF_ServiceConfig.SelectedIndex = 0 }
			$WPF_ServiceConfig.Items.RemoveAt(2)
			$Script:LaptopTweaked = 0
			$Script:BVCount--
			HideShowCustomSrvStuff
		}
	})

	$WPF_ShowDiagButton.Add_Click({
		UpdateSetting
		$WPF_TabControl.Items[4].Visibility = 'Visible'
		$WPF_TabControl.Items[4].IsSelected = $True
		$WPF_DiagnosticOutput.text = ''
		Clear-Host
		TBoxMessageD " Diagnostic Information below, will be copied to the clipboard.`n" 13
		$Script:DiagString = ''
		TBoxMessageD ' ********START********' 11
		TBoxMessageD ' Diagnostic Output, Some items may be blank' 14
		TBoxMessageD '' 14
		TBoxMessageD ' --------Script Info--------' 2
		TBoxMessageDL ' Script Version: ' $Script_Version
		TBoxMessageDL ' Release Type: ' $Release_Type
		TBoxMessageDL ' Services Version: ' $ServiceVersion
		TBoxMessageD '' 14
		TBoxMessageD ' --------System Info--------' 2
		TBoxMessageDL ' Window: ' $WindowVersion
		TBoxMessageDL ' Edition: ' $FullWinEdition
		TBoxMessageDL ' Edition SKU#: ' $WinSku
		TBoxMessageDL ' Build: ' $BuildVer
		TBoxMessageDL ' Version: ' $Win10Ver
		TBoxMessageDL ' PC Type: ' $PCType
		TBoxMessageDL ' Desktop/Laptop: ' $IsLaptop.Substring(1)
		TBoxMessageD '' 14
		TBoxMessageD ' --------Current Settings--------' 2
		TBoxMessageDL ' BlackViper: ' $WPF_ServiceConfig.Text
		If($All_or_Min -eq '-full'){ $TmpAoM = 'All' } Else { $TmpAoM = 'Min' }
		TBoxMessageDL ' All/Min: ' $TmpAoM
		TBoxMessageDL ' ToS: ' $AcceptToS
		TBoxMessageDL ' Automated: ' $Automated
		TBoxMessageDL ' ScriptVerCheck: ' $ScriptVerCheck
		TBoxMessageDL ' ServiceVerCheck: ' $ServiceVerCheck
		TBoxMessageDL ' InternetCheck: ' $InternetCheck
		TBoxMessageDL ' ShowAlreadySet: ' $ShowAlreadySet
		TBoxMessageDL ' ShowNonInstalled: ' $ShowNonInstalled
		TBoxMessageDL ' ShowSkipped: ' $ShowSkipped
		TBoxMessageDL ' XboxService: ' $XboxService
		TBoxMessageDL ' StopDisabled: ' $StopDisabled
		TBoxMessageDL ' EditionCheck: ' $EditionCheck
		TBoxMessageDL ' BuildCheck: ' $BuildCheck
		TBoxMessageDL ' DryRun: ' $DryRun
		TBoxMessageDL ' ScriptLog: ' $ScriptLog
		TBoxMessageDL ' LogName: ' $LogName
		TBoxMessageDL ' LogBeforeAfter: ' $LogBeforeAfter
		TBoxMessageDL ' DevLog: ' $DevLog
		TBoxMessageDL ' BackupServiceConfig: ' $BackupServiceConfig
		TBoxMessageDL ' BackupServiceType: ' $WPF_BackupServiceType.Text
		TBoxMessageDL ' BatUpdateScriptFileName: ' $BatUpdateScriptFileName
		TBoxMessageDL ' ShowConsole: ' $ShowConsole
		TBoxMessageDL ' LaptopTweaked: ' $LaptopTweaked
		TBoxMessageD '' 14
		TBoxMessageD ' --------Misc Info--------' 2
		TBoxMessageDL ' Run Button txt: ' $WPF_RunScriptButton.Content
		TBoxMessageDL ' Args: ' $PassedArg
		TBoxMessageD '' 14
		TBoxMessageD ' ********END********' 11
		$DiagString | Set-Clipboard
		[Windows.Forms.MessageBox]::Show('Diagnostic Information, has been copied to the clipboard.','Notice', 'OK') | Out-Null
	})

	$WPF_ShowConsole_CB.Add_Checked({ ShowConsoleWin 5 }) #5 = Show
	$WPF_ShowConsole_CB.Add_UnChecked({ ShowConsoleWin 0 }) #0 = Hide
	$WPF_ScriptLog_CB.Add_Checked({ $WPF_LogNameInput.IsEnabled = $True })
	$WPF_ScriptLog_CB.Add_UnChecked({ $WPF_LogNameInput.IsEnabled = $False })
	$WPF_CustomBVCB.Add_Checked({ CustomBVCBFun -C })
	$WPF_CustomBVCB.Add_UnChecked({ CustomBVCBFun })
	$WPF_btnOpenFile.Add_Click({ OpenSaveDiaglog 0 })
	$WPF_SaveCustomSrvButton.Add_Click({ OpenSaveDiaglog 1 })
	$WPF_SaveRegButton.Add_Click({ OpenSaveDiaglog 2 })
	$WPF_ContactButton.Add_Click({ OpenWebsite 'mailto:madbomb122@gmail.com' })
	$WPF_BlackViperWSButton.Add_Click({ OpenWebsite 'http://www.blackviper.com/' })
	$WPF_Madbomb122WSButton.Add_Click({ OpenWebsite 'https://github.com/madbomb122/' })
	$WPF_DonateButton.Add_Click({ ClickedDonate })
	$WPF_FeedbackButton.Add_Click({ OpenWebsite 'https://github.com/madbomb122/BlackViperScript/issues' })
	$WPF_FAQButton.Add_Click({ OpenWebsite 'https://github.com/madbomb122/BlackViperScript/blob/master/README.md' })
	$WPF_LoadServicesButton.Add_Click({ GenerateServices })
	$WPF_ACUcheckboxChecked.Add_Checked({ DGUCheckAll $True })
	$WPF_ACUcheckboxChecked.Add_UnChecked({ DGUCheckAll $False })
	$WPF_CheckUpdateSerButton.Add_Click({ UpdateCheckNow 1 })
	$WPF_CheckUpdateSrpButton.Add_Click({ UpdateCheckNow 2 })
	$WPF_CheckUpdateBothButton.Add_Click({ UpdateCheckNow 3 })
	$WPF_DevLogCB.Add_Checked({ DevLogCBFunction })
	$WPF_DevLogCB.Add_UnChecked({ DevLogCBFunction -C })

	$WPF_AboutButton.Add_Click({ [Windows.Forms.MessageBox]::Show("This script lets you set Windows 10's services based on Black Viper's Service Configurations, your own Service Configuration (If in a proper format), or a backup of your Service Configurations made by this script.`n`nThis script was created by MadBomb122.",'About', 'OK') | Out-Null })
	$WPF_CopyrightButton.Add_Click({ [Windows.Forms.MessageBox]::Show($CopyrightItems,'Copyright', 'OK') | Out-Null })

	$CopyrightItems = 'Copyright (c) 1999-2017 Charles "Black Viper" Sparks - Services Configuration

--------------------------------------------------------------------------------

The MIT License (MIT) + an added Condition

Copyright (c) 2017 Madbomb122 - Black Viper Service Configuration Script

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice(s), this permission notice and ANY original donation link shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'

	$Script:RunScript = 0
	If($All_or_Min -eq '-Full'){ $WPF_RadioAll.IsChecked = $True } Else{ $WPF_RadioMin.IsChecked = $True }
	$WPF_LogNameInput.Text = $LogName
	If($ScriptLog -eq 1) {
		$WPF_ScriptLog_CB.IsChecked = $True
		$WPF_LogNameInput.IsEnabled = $True
	}
	If($IsLaptop -eq '-Lap') {
		$WPF_ServiceConfig.Items.RemoveAt(2)
	} Else {
		$WPF_LaptopTweaked_CB.Visibility = 'Hidden'
		$WPF_LaptopTweaked_txt.Visibility = 'Hidden'
	}
	$Script:BVCount = $WPF_ServiceConfig.Items.Count

	ForEach($Var In $VarList){ If($(Get-Variable -Name ($Var.Name.Split('_')[1]) -ValueOnly) -eq 1){ $Var.Value.IsChecked = $True } Else{ $Var.Value.IsChecked = $False } }
	If($EditionCheck -ne 0){ $WPF_EditionCheckCB.IsChecked = $True ;$WPF_EditionConfig.IsEnabled = $True } Else{ $WPF_EditionCheckCB.IsChecked = $False }
	If($WinEdition -eq 'Home' -or $EditionCheck -eq 'Home'){ $WPF_EditionConfig.SelectedIndex = 0 } Else{ $WPF_EditionConfig.SelectedIndex = 1 }
	$WPF_BackupServiceType.SelectedIndex = $BackupServiceType

	If($Release_Type -ne 'Stable') {
		If($ShowConsole -eq 1){ $WPF_ShowConsole_CB.IsChecked = $True }
		$WPF_ShowConsole_CB.Visibility = 'Hidden'
	} Else {
		If($ShowConsole -eq 0){ ShowConsoleWin 0 }
	}

	$WPF_ServiceConfig.SelectedIndex = $Black_Viper
	$WPF_LoadFileTxtBox.Text = $ServiceConfigFile
	$WPF_LoadServicesButton.IsEnabled = SetServiceVersion
	$WPF_Script_Ver_Txt.Text = "Script Version: $Script_Version ($Script_Date) -$Release_Type"
	$WPF_Service_Ver_Txt.Text = "Service Version: $ServiceVersion ($ServiceDate)"

	$Script:ServiceImport = 1
	HideShowCustomSrvStuff
	RunDisableCheck
	Clear-Host
	DisplayOut 'Displaying GUI Now' -C 14
	DisplayOut "`nTo exit you can close the GUI or PowerShell Window." -C 14
	$Form.ShowDialog() | Out-Null
}

Function CustomBVCBFun {
	Param( [Switch]$C )
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
	If(!($EditionCheck -eq 'Home' -or $EditionCheck -eq 'Pro' -or $WinSkuList -Contains $WinSku)){ $EBFailCount = 1 }
	If($Win10Ver -lt $MinVer -And $BuildCheck -ne 1){ $EBFailCount += 2 }

	If($EBFailCount -ne 0) {
		$Buttontxt = 'Run Disabled Due to '
		$Buttontxt += $EBErrLst[$EBFailCount -1]
		$WPF_RunScriptButton.IsEnabled = $False
		$Buttontxt += ' Check'
		$WPF_dataGrid.Columns[4].Header = 'Black Viper'
	} ElseIf($WPF_ServiceConfig.SelectedIndex + 1 -eq $BVCount) {
		$WPF_RunScriptButton.IsEnabled = $False
		$WPF_LoadServicesButton.IsEnabled = $False
		If(!($ServiceConfigFile) -or !(Test-Path -LiteralPath $ServiceConfigFile -PathType Leaf)) {
			$Buttontxt = "Run Disabled, No Custom Service List File Selected or Doesn't exist."
		} Else {
			[System.Collections.ArrayList]$Tempcheck = Import-Csv -LiteralPath $ServiceConfigFile
			If($Tempcheck[0].StartType -eq $null -or $Tempcheck[0].ServiceName -eq $null) {
				$Buttontxt = 'Run Disabled, Invalid Custom Service File.'
			} Else {
				$WPF_LoadServicesButton.IsEnabled = $True
				$WPF_RunScriptButton.IsEnabled = $True
				$Buttontxt = 'Run Script with Custom Service List'
			}
		}
		$WPF_dataGrid.Columns[4].Header = 'Custom Service'
	} Else {
		If($WPF_ServiceConfig.SelectedIndex -eq 0){ $WPF_dataGrid.Columns[4].Header = 'Win Default' } Else{ $WPF_dataGrid.Columns[4].Header = 'Black Viper' }
		If($WPF_CustomBVCB.IsChecked){ $Buttontxt = 'Run Script with Customize Service List' } Else{ $Buttontxt = 'Run Script' }
		$WPF_RunScriptButton.IsEnabled = $True
	}
	$WPF_RunScriptButton.Content = $Buttontxt
}

Function GenerateServices {
#	StartMode = StartType
#	Get-CimInstance Win32_service | Select-Object DisplayName, Name, StartMode, Description, PathName

	If($SrvCollected -ne 0){ $Script:ServiceInfo = Get-CimInstance Win32_service | Select-Object Name, Description, PathName, State ;$Script:SrvCollected = 1 }
	$Black_Viper = $WPF_ServiceConfig.SelectedIndex + 1
	If($Black_Viper -eq $BVCount) {
		If($Script:ServiceGen -eq 0){ $Script:ServiceImport = 1 }
		$Script:LoadServiceConfig = 1
		$ServiceFilePath = $WPF_LoadFileTxtBox.Text
		$ServiceGen = 1
	} Else {
		If($Script:ServiceGen -eq 1){ $Script:ServiceImport = 1 }
		If($WPF_RadioAll.IsChecked){ $FullMin = '-Full' } Else{ $FullMin = '-Min' }
		$Script:LoadServiceConfig = 0
		$ServiceFilePath = $filebase + 'BlackViper.csv'
		$ServiceGen = 0
	}
	If($LoadServiceConfig -eq 1) {
		$Script:BVService = 'StartType'
	} ElseIf($Black_Viper -eq 1) {
		$Script:BVService = "Def-$WinEdition$FullMin" ;$BVSAlt = "Def-$WinEdition-Full"
	} ElseIf($Black_Viper -eq 2) {
		$Script:BVService = "Safe$IsLaptop$FullMin" ;$BVSAlt = "Safe$IsLaptop-Full"
	} ElseIf($Black_Viper -eq 3) {
		$Script:BVService = "Tweaked-Desk$FullMin" ;$BVSAlt = "Tweaked-Desk-Full"
	}
	If($WPF_XboxService_CB.IsChecked){ $Script:XboxService = 1 } Else{ $Script:XboxService = 0 }
	If($ServiceImport -eq 1) {
		[System.Collections.ArrayList]$ServCB = Import-Csv -LiteralPath $ServiceFilePath
		$ServiceImport = 0
	}
	[System.Collections.ArrayList]$Script:DataGridListOrig = @{}
	[System.Collections.ArrayList]$Script:DataGridListCust = @{}

	ForEach($item In $ServCB) {
		$ServiceName = $item.ServiceName
		If($ServiceName -Like '*_*'){ $ServiceName = Get-Service ($ServiceName.Split('_')[0] + '_*') | Select-Object Name }
		If($CurrServices.Name -Contains $ServiceName) {
			$tmp = $ServiceInfo -match $ServiceName
			$SrvDescription = $tmp.Description
			If($SrvDescription -Is [system.array]){ $SrvDescription = $SrvDescription[0] }
			$SrState = $tmp.State
			$SrvPath = $tmp.PathName
			If($SrvPath -Is [system.array]){ $SrvPath = $SrvPath[0] }
			$ServiceTypeNum = $item.$BVService
			$ServiceCurrType = ($CurrServices.Where{$_.Name -eq $ServiceName}).StartType
			If($ServiceCurrType -eq 'Disabled') {
				$ServiceCurrType = $ServicesTypeFull[1]
			} ElseIf($ServiceCurrType -eq 'Manual') {
				$ServiceCurrType = $ServicesTypeFull[2]
			} ElseIf($ServiceCurrType -eq 'Auto') {
				If(AutoDelayTest $ServiceName -eq 1){ $ServiceCurrType = $ServicesTypeFull[4] } Else{ $ServiceCurrType = $ServicesTypeFull[3] }
			}
			If($ServiceTypeNum -eq 0) {
				$checkbox = $False
				$ServiceTypeNum = $item.$BVSAlt
			} ElseIf($XboxService -eq 1 -and $XboxServiceArr -Contains $ServiceName) {
				$checkbox = $False
			} Else {
				$checkbox = $True
			}
			$ServiceType = $ServicesTypeFull[$ServiceTypeNum]
			If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
			$ServiceCommName = ($CurrServices.Where{$_.Name -eq $ServiceName}).DisplayName
			If($ServiceType -eq  $ServiceCurrType){ $Match = $True } Else{ $Match = $False }
			$Script:DataGridListOrig += [PSCustomObject] @{ CheckboxChecked = $checkbox ;CName = $ServiceCommName ;ServiceName = $ServiceName ;CurrType = $ServiceCurrType ;BVType = $ServiceType ;StartType = $ServiceTypeNum ;ServiceTypeListDG = $ServicesTypeFull ;SrvStateListDG = $SrvStateList ;SrvState = $SrState ;SrvDesc = $SrvDescription ;SrvPath = $SrvPath ;Matches = $Match }
			$Script:DataGridListCust += [PSCustomObject] @{ CheckboxChecked = $checkbox ;CName = $ServiceCommName ;ServiceName = $ServiceName ;CurrType = $ServiceCurrType ;BVType = $ServiceType ;StartType = $ServiceTypeNum ;ServiceTypeListDG = $ServicesTypeFull ;SrvStateListDG = $SrvStateList ;SrvState = $SrState ;SrvDesc = $SrvDescription ;SrvPath = $SrvPath ;Matches = $Match }
		}
	}
	$WPF_dataGrid.ItemsSource = $DataGridListOrig
#	$test = $DataGridListOrig | Select-Object checkboxChecked, CName, ServiceName, CurrType, BVType, SrvDesc, SrvPath | Out-GridView -PassThru

	If(!($ServicesGenerated)) {
		$WPF_ServiceClickLabel.Visibility = 'Hidden'
		$WPF_ServiceNote.Visibility = 'Visible'
		$WPF_CustomBVCB.Visibility = 'Visible'
		$WPF_SaveCustomSrvButton.Visibility = 'Visible'
		$WPF_SaveRegButton.Visibility = 'Visible'
		$WPF_TableLegend.Visibility = 'Visible'
		$WPF_Div1.Visibility = 'Visible'
		$WPF_LoadServicesButton.Content = 'Reload'
		$Script:ServicesGenerated = $True
	}
}

Function BVTypeNameToNumb([String]$Name) {
	If($Name -eq 'Skip'){ Return 0 }
	If($Name -eq 'Disabled'){ Return 1 }
	If($Name -eq 'Manual'){ Return 2 }
	If($Name -eq 'Automatic'){ Return 3 }
	Return 4
}

Function DGUCheckAll([Bool]$C) {
	ForEach($item in $DataGridListCust){ $item.CheckboxChecked = $C }
	$WPF_dataGrid.Items.Refresh()
}

Function TBoxMessageD([String]$msg,[Int]$Clr) {
	$WPF_DiagnosticOutput.Dispatcher.Invoke(
		[action]{
			$Run = New-Object System.Windows.Documents.Run
			$Run.Foreground = $colorsGUI[$Clr]
			$Run.Text = $msg
			$WPF_DiagnosticOutput.Inlines.Add($Run)
			$WPF_DiagnosticOutput.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
		},"Normal"
	)
	$Script:DiagString += "$Message`n"
	DisplayOut $msg -C $Clr
}

Function TBoxMessageDL([String]$msg1,[String]$msg2) {
	$WPF_DiagnosticOutput.Dispatcher.Invoke(
		[action]{
			$Run = New-Object System.Windows.Documents.Run
			$Run.Foreground = $colorsGUI[14]
			$Run.Text = $msg1
			$WPF_DiagnosticOutput.Inlines.Add($Run)
			$Run = New-Object System.Windows.Documents.Run
			$Run.Foreground = $colorsGUI[15]
			$Run.Text = $msg2
			$WPF_DiagnosticOutput.Inlines.Add($Run)
			$WPF_DiagnosticOutput.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
		},"Normal"
	)
	$Script:DiagString += "$msg1 $msg2 `n"
	DisplayOut $msg1,$msg2 -C 14,15
}

##########
# GUI -End
##########
# Update Functions -Start
##########

Function InternetCheck { If($InternetCheck -eq 1 -or (Test-Connection www.GitHub.com -Count 1 -Quiet)){ Return $True } Return $False }

Function UpdateCheckAuto {
	If(InternetCheck) {
		UpdateCheck 0
	} Else {
		$Script:ErrorDi = 'No Internet'
		Error_Top_Display
		DisplayOutLML 'No Internet connection detected or GitHub.com' -C 2 -L
		DisplayOutLML 'is currently down.' -C 2 -L
		DisplayOutLML 'Tested by pinging GitHub.com' -C 2 -L
		MenuBlankLine -L
		DisplayOutLML 'To skip use one of the following methods' -C 2 -L
		DisplayOut '|',' 1. Run Script or bat file with ','-sic',' argument'.PadRight(16),'|' -C 14,2,15,2,14 -L
		DisplayOut '|',' 2. Change ','InternetCheck',' in Script file'.PadRight(28),'|' -C 14,2,15,2,14 -L
		DisplayOut '|',' 3. Change ','InternetCheck',' in bat file'.PadRight(28),'|' -C 14,2,15,2,14 -L
		MenuBlankLine -L
		MenuBlankLineLog -L
		If(!(Test-Path -LiteralPath $ServiceFilePath -PathType Leaf)) {
			MenuBlankLine -L
			DisplayOut '|',' The File ','BlackViper.csv',' is missing and the script  ','|' -C 14,2,15,2,14 -L
			DisplayOutLML "can't run w/o it." -C 2 -L
			MenuBlankLine -L
			MenuBlankLineLog -L
			AutomatedExitCheck 1
		} Else {
			AutomatedExitCheck 0
		}
	}
}

Function UpdateCheckNow([Int]$Switch) {
	SaveSetting
	If(InternetCheck) {
		UpdateCheck $Switch
	} Else {
		$Script:ErrorDi = 'No Internet'
		[Windows.Forms.MessageBox]::Show('No Internet connection detected or GitHub is down. If you are connected to the internet, Click the Skip internet checkbox.','Error: No Internet', 'OK','Error') | Out-Null
	}
}

Function UpdateCheck([Int]$USwitch) {
	$Switch = 1
	$Message = ''
	$CSV_Ver = Invoke-WebRequest $Version_Url | ConvertFrom-Csv
	If($USwitch -eq 0) {
		$Switch = 0
	} ElseIf($USwitch -eq 1) {
		$SerCheck = 1 ;$SrpCheck = 0
	} ElseIf($USwitch -eq 2) {
		$SerCheck = 0 ;$SrpCheck = 1
	} ElseIf($USwitch -eq 3) {
		$SerCheck = 1 ;$SrpCheck = 3
	}

	If($SerCheck -eq 1 -or $ServiceVerCheck -eq 1) {
		$WebVersion = $CSV_Ver[1].Version
		If($ServiceVersion -eq 'Missing File'){ $ServVer = '0.0' } Else{ $ServVer = $ServiceVersion }
		If($LoadServiceConfig  -In 0,1 -And $WebVersion -gt $ServVer) {
			$Choice = 'Yes'
			If($Switch -eq 1) {
				If($ServiceVersion -eq 'Missing File') {
					$UpdateFound = 'Download Missing BlackViper.csv file?'
					$UpdateTitle = 'Missing File'
				} Else {
					$UpdateFound = 'Update Service File from $WebVersion to $ServVer ?'
					$UpdateTitle = 'Update Found'
				}
				$Choice = [windows.forms.messagebox]::show($UpdateFound,$UpdateTitle,'YesNo') | Out-Null
			}
			If($Choice -eq 'Yes') {
				If($ScriptLog -eq 1){ Write-Output "Downloading update for 'BlackViper.csv'" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append}
				DownloadFile $Service_Url $ServiceFilePath
				If($LoadServiceConfig -ne 2){ [System.Collections.ArrayList]$Script:csv = Import-Csv -LiteralPath $ServiceFilePath }
			} ElseIf($SrpCheck -ne 1) {
				$Switch = 0
			}
		} ElseIf($Switch -eq 1) {
			$Message = 'No Service update Found.'
		}
	}
	If($SrpCheck -eq 1 -or $ScriptVerCheck -eq 1) {
		If($Release_Type -eq 'Stable'){ $CSVLine = 0 } Else{ $CSVLine = 2 }
		$WebScriptVer = $CSV_Ver[$CSVLine].Version + "." + $CSV_Ver[$CSVLine].MinorVersion
		If($WebScriptVer -gt $Script_Version){
			$Choice = 'Yes'
			If($Switch -eq 1){ $Choice = [windows.forms.messagebox]::show("Update Script File from $Script_Version to $WebScriptVer ?",'Update Found','YesNo') | Out-Null }
			If($Choice -eq 'Yes'){ ScriptUpdateFun } ElseIf($Message -eq ''){ $Switch = 0 }
		} ElseIf($Switch -eq 1) {
			If($Message -eq ''){ $Message = 'No Script update Found.' } Else{ $Message = 'Congrats you have the latest Service and Script version.' }
		}
	}
	If($Switch -eq 1){ [windows.forms.messagebox]::show($Message,'Update','OK') | Out-Null }
}

Function UpdateDisplay([String]$FullVer,[String]$DFilename) {
	Clear-Host
	MenuBlankLineLog -L
	DisplayOutLML (''.PadRight(18)+'Update Found!') -C 13 -L
	MenuBlankLineLog -L
	MenuBlankLine -L
	DisplayOut '|',' Downloading version ',"$FullVer".PadRight(31),'|' -C 14,15,11,14 -L
	DisplayOut '|',' Will run ',$DFilename.PadRight(42),'|' -C 14,15,11,14 -L
	DisplayOutLML 'after download is complete.' -C 15 -L
	MenuBlankLine -L
	MenuBlankLineLog -L
}

Function ScriptUpdateFun {
	$FullVer = "$WebScriptVer.$WebScriptMinorVer"
	$UpdateFile = $filebase + 'Update.bat'
	$UpArg = ''
	If(!$GuiSwitch) {
		If($Black_Viper -eq 1){ $UpArg += '-default ' } ElseIf($Black_Viper -eq 2){ $UpArg += '-safe ' } ElseIf($Black_Viper -eq 3){ $UpArg += '-tweaked ' }
		If($LoadServiceConfig -eq 1) {
			$UpArg += "-lcsc $ServiceConfigFile "
		} ElseIf($LoadServiceConfig -eq 2) {
			$TempSrv = $Env:Temp + '\TempSrv.csv' ;$Script:csv | Export-Csv -LiteralPath $TempSrv -Encoding Unicode -Force -Delimiter ',' ;$UpArg += "-lcsc $TempSrv "
		}
		If($Automated -eq 1){ $UpArg += '-auto ' }
	}
	If($EditionCheck-eq 'Home'){ $UpArg += '-sech ' } ElseIf($EditionCheck -eq 'Pro'){ $UpArg += '-secp ' }
	If($AcceptToS -ne 0){ $UpArg += '-atosu ' }
	If($ServiceVerCheck -eq 1){ $UpArg += '-use ' }
	If($InternetCheck -eq 1){ $UpArg += '-sic ' }
	If($BuildCheck -eq 1){ $UpArg += '-sbc ' }
	If($Diagnostic -eq 1){ $UpArg += '-diag ' }
	If($LogBeforeAfter -eq 1){ $UpArg += '-baf ' }
	If($DryRun -eq 1){ $UpArg += '-dry ' }
	If($ShowSkipped -eq 1){ $UpArg += '-sss ' }
	If($DevLog -eq 1){ $UpArg += '-devl ' }
	If($ScriptLog -eq 1){ $UpArg += "-logc $LogName " }
	If($All_or_Min -eq '-Full'){ $UpArg += '-all ' } Else{ $UpArg += '-Min ' }
	If($XboxService -eq 1){ $UpArg += '-sxb ' }
	If($ShowNonInstalled -eq 1){ $UpArg += '-snis ' }
	If($BackupServiceConfig -eq 1) {
		If($BackupServiceType -eq 1){ $UpArg += '-bscr ' } ElseIf($BackupServiceType -eq 2){ $UpArg += '-bscc ' } ElseIf($BackupServiceType -eq 3){ $UpArg += '-bscb ' }
	}

	If(Test-Path -LiteralPath $UpdateFile -PathType Leaf) {
		$DFilename = 'BlackViper-Win10.ps1'
		$UpArg += '-u -bv '
		If($Release_Type -ne 'Stable'){ $UpArg += '-test ' }
		UpdateDisplay $FullVer $DFilename
		cmd.exe /c "$UpdateFile $UpArg"
	} Else {
		$DFilename = 'BlackViper-Win10-Ver.' + $FullVer
		If($Release_Type -ne 'Stable') {
			$DFilename += '-Testing'
			$Script_Url = $URL_Base + 'Testing/'
		}
		$DFilename += '.ps1'
		$Script_Url = $URL_Base + 'BlackViper-Win10.ps1'
		$WebScriptFilePath = $filebase + $DFilename
		UpdateDisplay $FullVer $DFilename
		DownloadFile $Script_Url $WebScriptFilePath
		If($BatUpdateScriptFileName -eq 1) {
			$BatFile = $filebase + '_Win10-BlackViper.bat'
			If(Test-Path -LiteralPath $BatFile -PathType Leaf) {
				(Get-Content -LiteralPath $BatFile) | Foreach-Object {$_ -replace "Set Script_File=.*?$" , "Set Script_File=$DFilename"} | Set-Content -LiteralPath $BatFile -Force
				MenuBlankLine -L
				DisplayOutLML 'Updated bat file with new script file name.' 13 -L
				MenuBlankLine -L
				MenuBlankLineLog -L
			}
		}
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$WebScriptFilePath`" $UpArg" -Verb RunAs
	}
	If($GuiSwitch){ $Form.Close() } ;Exit
}

##########
# Update Functions -End
##########
# Log/Backup Functions -Start
##########

Function ServiceBAfun([String]$ServiceBA) {
	If($LogBeforeAfter -eq 1) {
		$ServiceBAFile = "$filebase$Env:computername-$ServiceBA.log"
		If($ServiceBA -eq 'Services-Before'){ $CurrServices | Out-File -LiteralPath $ServiceBAFile } Else{ Get-Service | Select-Object DisplayName, StartType | Out-File -LiteralPath $ServiceBAFile }
	} ElseIf($LogBeforeAfter -eq 2) {
		If($ServiceBA -eq 'Services-Before'){ $TMPServices = $CurrServices } Else{ $TMPServices = Get-Service | Select-Object DisplayName, Name, StartType }
		Write-Output "`n$ServiceBA -Start" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output ''.PadRight(37,'-') | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output $TMPServices | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output ''.PadRight(37,'-') | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
		Write-Output "$ServiceBA -End`n" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append
	}
}

Function Save_Service([String]$SavePath) {
	$ServiceSavePath = $filebase + $Env:computername
	$SaveService = @()

	If($WPF_CustomBVCB.IsChecked) {
		$ServiceSavePath += '-Custom-Service.csv'
		$ServiceCBList = $WPF_dataGrid.Items.Where({$_.CheckboxChecked -eq $True})
		ForEach($item In $ServiceCBList) {
			$ServiceName = $item.ServiceName
			$BVTypeS = BVTypeNameToNumb $item.BVType
			If($ServiceName -Like "*_$ServiceEnd"){ $ServiceName = $ServiceName.Split('_')[0] + '_?????' }
			$SaveService += [PSCustomObject] @{ ServiceName = $ServiceName ;StartType = $BVTypeS }
		}
	} Else {
		If($AllService -eq $null){ $ServiceSavePath += '-Service-Backup.csv' ;GetAllServices } Else{ $ServiceSavePath += '-Custom-Service.csv' }
		$SaveService = GenerateSaveService
	}
	If($SavePath -ne $null){ $ServiceSavePath = $SavePath}
	$SaveService | Export-Csv -LiteralPath $ServiceSavePath -Encoding Unicode -Force -Delimiter ','
	If($SavePath -ne $null){ [Windows.Forms.MessageBox]::Show("File saved as '$SavePath'",'File Saved', 'OK') | Out-Null }
}

Function Save_ServiceBackup {
	$SaveService = @()
	$ServiceSavePath = $filebase + $Env:computername + '-Service-Backup.csv'
	If($AllService -eq $null){ GetAllServices }
	$SaveService = GenerateSaveService
	$SaveService | Export-Csv -LiteralPath $ServiceSavePath -Encoding Unicode -Force -Delimiter ','
}

Function GenerateSaveService {
	$TMPServiceL = @()
	ForEach($Service In $AllService) {
		$ServiceName = $Service.Name
		If(!($Skip_Services -Contains $ServiceName)) {
			$tmp = $Service.StartType
			If($tmp -eq 'Disabled') {
				$StartType = 1
			} ElseIf($tmp -eq 'Manual') {
				$StartType = 2
			} ElseIf($tmp -eq 'Automatic') {
				If(AutoDelayTest $ServiceName -eq 1){ $StartType = 4 } Else{ $StartType = 3 }
			} Else {
				$StartType = $tmp
			}
			If($ServiceName -Like "*_$ServiceEnd"){ $ServiceName = $ServiceName.Split('_')[0] + '_?????' }
			$TMPServiceL += [PSCustomObject] @{ ServiceName = $ServiceName ;StartType = $StartType }
		}
	}
	Return $TMPServiceL
}

Function RegistryServiceFileBackup {
	$SavePath = $filebase + $Env:computername
	$SavePath += '-Service-Backup.reg'
	If($WPF_CustomBVCB.IsChecked){ GenerateRegistryCustom $SavePath } Else{ GenerateRegistryRegular $SavePath }
}

Function RegistryServiceFile([String]$TempFP) {
	If($WPF_CustomBVCB.IsChecked){ GenerateRegistryCustom $TempFP } Else{ GenerateRegistryRegular $TempFP }
	[Windows.Forms.MessageBox]::Show("Registry File saved as '$TempFP'",'File Saved', 'OK') | Out-Null
}

Function GenerateRegistryRegular([String]$TempFP) {
	If($AllService -eq $null){ GetAllServices }
	Write-Output "Windows Registry Editor Version 5.00`n" | Out-File -LiteralPath $TempFP
	ForEach($Service In $AllService) {
		$ServiceName = $Service.Name
		If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
		If(!($Skip_Services -Contains $ServiceName)) {
			$tmp = $Service.StartType
			If($tmp -eq 'Disabled'){ $ServiceTypeNum = 4 } ElseIf($tmp -eq 'Manual'){ $ServiceTypeNum = 3 } ElseIf($tmp -eq 'Automatic'){ $ServiceTypeNum = 2 }
			$Num = '"Start"=dword:0000000' + $ServiceTypeNum
			Write-Output "[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$ServiceName]" | Out-File -LiteralPath $TempFP -Append
			Write-Output $Num | Out-File -LiteralPath $TempFP -Append
			If($ServiceTypeNum -eq 2 -and (AutoDelayTest $ServiceName -eq 1)){ Write-Output '"DelayedAutostart"=dword:00000001' | Out-File -LiteralPath $TempFP -Append }
			Write-Output '' | Out-File -LiteralPath $TempFP -Append
		}
	}
}

Function GenerateRegistryCustom([String]$TempFP) {
	$ServiceCBList = $WPF_dataGrid.Items.Where({$_.CheckboxChecked -eq $True})
	Write-Output "Windows Registry Editor Version 5.00`n" | Out-File -LiteralPath $TempFP
	ForEach($item In $ServiceCBList) {
		$ServiceName = $item.ServiceName
		$ServiceTypeNum = BVTypeNameToNumb $item.BVType
		If($ServiceTypeNum -ne 0) {
			If($ServiceName -Like '*_*'){ $ServiceName = Get-Service ($ServiceName.Split('_')[0] + '_*') | Select-Object Name }
			If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
			If(!($Skip_Services -Contains $ServiceName)) {
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
		$Script:LogFile = $filebase + $LogName
		$Time = Get-Date -Format g
		If($ScriptLog -eq 2) {
			Write-Output 'Updated Script File running' | Out-File -LiteralPath $LogFile -Encoding Unicode -NoNewline -Append
			Write-Output "--Start of Log ($Time)--" | Out-File -LiteralPath $LogFile -Encoding Unicode -NoNewline -Append
			$ScriptLog = 1
		} Else {
			Write-Output "--Start of Log ($Time)--" | Out-File -LiteralPath $LogFile -Encoding Unicode
		}
	}
	$Script:LogStarted = 1
}

Function DiagnosticCheck([Int]$Bypass) {
	If($Release_Type -ne 'Stable' -or $Bypass -eq 1 -or $Diagnostic -eq 1) {
		DisplayOut " ********START********" -C 11
		DisplayOut ' Diagnostic Output, Some items may be blank' -C 14
		DisplayOut "`n --------Script Info--------" -C 2
		DisplayOut ' Script Version: ',$Script_Version -C 14,15
		DisplayOut ' Release Type: ',$Release_Type -Color 14,15
		If(!(Test-Path -LiteralPath ($filebase + 'BlackViper.csv') -PathType Leaf)){ $SrvFileExist = 'Missing' } Else{ $SrvFileExist = 'Exist' }
		DisplayOut ' Service File: ',$SrvFileExist -C 14,15
		DisplayOut "`n --------System Info--------" -C 2
		DisplayOut ' Window: ',$WindowVersion -C 14,15
		DisplayOut ' Edition: ',$FullWinEdition -C 14,15
		DisplayOut ' Edition SKU#: ',$WinSku -C 14,15
		DisplayOut ' Build: ',$BuildVer -C 14,15
		DisplayOut ' Version: ',$Win10Ver -C 14,15
		DisplayOut ' PC Type: ',$PCType -C 14,15
		DisplayOut ' Desktop/Laptop: ',$IsLaptop.Substring(1) -C 14,15
		DisplayOut "`n --------Misc Info--------" -C 2
		DisplayOut ' Args: ',$PassedArg -C 14,15
		DisplayOut ' Error: ',$ErrorDi -C 13,15
		DisplayOut "`n --------Settings--------" -C 2
		DisplayOut ' BlackViper: ',$Black_Viper -C 14,15
		If($All_or_Min -eq '-full'){ $TmpAoM = 'All' } Else { $TmpAoM = 'Min' }
		DisplayOut ' All/Min: ',$TmpAoM -C 14,15
		DisplayOut ' ToS: ',$AcceptToS -C 14,15
		DisplayOut ' Automated: ',$Automated -C 14,15
		DisplayOut ' ScriptVerCheck: ',$ScriptVerCheck -C 14,15
		DisplayOut ' ServiceVerCheck: ',$ServiceVerCheck -C 14,15
		DisplayOut ' InternetCheck: ',$InternetCheck -C 14,15
		DisplayOut ' ShowAlreadySet: ',$ShowAlreadySet -C 14,15
		DisplayOut ' ShowNonInstalled: ',$ShowNonInstalled -C 14,15
		DisplayOut ' ShowSkipped: ',$ShowSkipped -C 14,15
		DisplayOut ' XboxService: ',$XboxService -C 14,15
		DisplayOut ' StopDisabled: ',$StopDisabled -C 14,15
		DisplayOut ' EditionCheck: ',$EditionCheck -C 14,15
		DisplayOut ' BuildCheck: ',$BuildCheck -C 14,15
		DisplayOut ' DryRun: ',$DryRun -C 14,15
		DisplayOut ' ScriptLog: ',$ScriptLog -C 14,15
		DisplayOut ' LogName: ',$LogName -C 14,15
		DisplayOut ' LogBeforeAfter: ',$LogBeforeAfter -C 14,15
		DisplayOut ' DevLog: ',$DevLog -C 14,15
		DisplayOut ' BackupServiceConfig: ',$BackupServiceConfig -C 14,15
		DisplayOut ' BackupServiceType: ',$BackupServiceType -C 14,15
		DisplayOut ' BatUpdateScriptFileName: ',$BatUpdateScriptFileName -C 14,15
		DisplayOut ' ShowConsole: ',$ShowConsole -C 14,15
		DisplayOut ' LaptopTweaked: ',$LaptopTweaked -C 14,15
		DisplayOut "`n ********END********" -C 11
	}
}

##########
# Log/Backup Functions -End
##########
# Service Change Functions -Start
##########

Function TBoxMessage {
	[Alias ("T")] [String[]]$Text,
	[Alias ("C")] [Int[]]$Color = 14,
	$WPF_ServiceListing.Dispatcher.Invoke(
		[action]{
			$Run = New-Object System.Windows.Documents.Run
			$Clr = $Color[0]
			$Run.Foreground = $colorsGUI[$Clr]
			$Run.Text = $Text[0]
			$WPF_ServiceListing.Inlines.Add($Run)
			If($Text[1] -ne $null) {
				$Run = New-Object System.Windows.Documents.Run
				$Clr = $Color[1]
				$Run.Foreground = $colorsGUI[$Clr]
				$Run.Text = $Text[1]
				$WPF_ServiceListing.Inlines.Add($Run)
			}
			$WPF_ServiceListing.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
		},"Normal"
	)
}

Function Black_Viper_Set([Int]$BVOpt,[String]$FullMin) {
	PreScriptCheck
	If($LoadServiceConfig -In 1,2) {
		$ServiceSetOpt = 'StartType' ;$SrvSetting = 'Custom'
	} ElseIf($Black_Viper -eq 1) {
		$ServiceSetOpt = "Def-$WinEdition$FullMin" ;$SrvSetting = 'Default'
	} ElseIf($Black_Viper -eq 2) {
		$ServiceSetOpt = "Safe$IsLaptop$FullMin" ;$SrvSetting = 'Safe'
	} ElseIf($Black_Viper -eq 3) {
		$ServiceSetOpt = "Tweaked-Desk$FullMin" ;$SrvSetting = 'Tweaked'
	}
	Clear-Host
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
	If($DryRun -ne 1){ DisplayOut ' Changing Service Please wait...' 14 0 -G:$GuiSwitch ;$StopWatch.Start() } Else{ DisplayOut ' List of Service that would be changed on Non-Dry Run/Dev Log...' 14 0 -G:$GuiSwitch }
	DisplayOut ' Service Setting: ',$BVSet -C 14,15 -L -G:$GuiSwitch
	DisplayOut ' Service_Name - Current -> Change_To' -C 14 -L -G:$GuiSwitch
	DisplayOut ''.PadRight(40,'-') -C 14 -L -G:$GuiSwitch
	ForEach($item In $csv) {
		$DispTempT = @()
		$DispTempC = @()
		$ServiceTypeNum = $item.$BVService
		$ServiceType = $ServicesTypeList[$ServiceTypeNum]
		$ServiceName = $item.ServiceName
		$ServiceCommName = ($CurrServices.Where{$_.Name -eq $ServiceName}).DisplayName
		If($ServiceName -Like '*_*'){ $ServiceName = (Get-Service ($ServiceName.Split('_')[0] + '_*') | Select-Object Name).Name }
		$ServiceCurrType = ServiceCheck $ServiceName $ServiceType
		$State = $item.SrvState
		If($ServiceName -eq $null -or $null -eq $ServiceName) {
			$ServiceTypeNum = 9
		} ElseIf($ServiceTypeNum -eq 0) {
			If($ShowSkipped -eq 1) {
				If($ServiceCommName -ne $null){ $DispTempT += " Skipping $ServiceCommName ($ServiceName)" } Else{ $DispTempT += " Skipping $ServiceName" }
				$DispTempC += 14
			}
			$ServiceTypeNum = 9
			$BVSkipped++
		} ElseIf($ServiceTypeNum -In 1..4) {
			If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
			If($ServicesTypeList -Contains $ServiceCurrType) {
				$DispTemp = " $ServiceCommName ($ServiceName) - $ServiceCurrType -> $ServiceType"
				If($DryRun -ne 1){ Set-Service $ServiceName -StartupType $ServiceType }
				If($ServiceTypeNum -eq 4) {
					$DispTemp += ' (Delayed)'
					If($DryRun -ne 1){ AutoDelaySet $ServiceName 1 }
				}
				$DispTempT += $DispTemp
				$DispTempC += 11
				$BVChanged++
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
					$BVChanged++
					$DispTempT += $DispTemp
					$DispTempC += 11
				} Else {
					If($ShowAlreadySet -eq 1) {
						$DispTemp += "is already $ServiceType"
						If($ServiceTypeNum -eq 4){ $DispTemp += ' (Delayed)' }
						$DispTempT += $DispTemp
						$DispTempC += 15
					}
					$BVAlready++
				}
			} ElseIf($ServiceCurrType -eq 'None') {
				If($ShowNonInstalled -eq 1){ DisplayOut " No service with name $ServiceName"  13 0 -G:$GuiSwitch }
				$ServiceTypeNum = 9
			} ElseIf($ServiceCurrType -eq 'Xbox') {
				DisplayOut " $ServiceCommName ($ServiceName) is an Xbox Service and will be skipped" -C 2 -L -G:$GuiSwitch
				$ServiceTypeNum = 9
				$BVSkipped++
			} ElseIf($ServiceCurrType -eq 'Denied') {
				If($Release_Type -eq 'Testing'){ DisplayOut " $ServiceCommName ($ServiceName) can't be changed." -C 14 -L -G:$GuiSwitch }
				$ServiceTypeNum = 9
			}
			If($DryRun -ne 1) {
				If($StopDisabled -eq 1 -and $ServiceTypeNum -eq 1) {
					If(($CurrServices.Where{$_.Name -eq $ServiceName}).Status -eq 'Running') {
						$DispTempT += ' -Stopping Service'
						$DispTempC += 13
						Stop-Service $ServiceName
						$BVStopped++
					} Else {
						$DispTempT += ' -Already Stopped'
						$DispTempC += 11
					}
				}
			}
		} Else {
			DisplayOut " Error: $ServiceName does not have a valid Setting." -C 13 -L -G:$GuiSwitch
		}
		If($DispTempT.count -ne 0){ DisplayOut $DispTempT -C $DispTempC -L -G:$GuiSwitch }
	}
	DisplayOut ''.PadRight(40,'-') -C 14 -L -G:$GuiSwitch

	If($DryRun -ne 1) {
		$StopWatch.Stop()
		$StopWatchTime = $StopWatch.Elapsed
		$StopWatch.Reset()
		DisplayOut ' Service Changed...' -C 14 -L -G:$GuiSwitch
		DisplayOut ' Changed: ',$BVChanged -C 14,15 -L -G:$GuiSwitch
		DisplayOut ' Already: ',$BVAlready -C 14,15 -L -G:$GuiSwitch
		DisplayOut ' Skipped: ',$BVSkipped -C 14,15 -L -G:$GuiSwitch
		If($StopDisabled -eq 1){ DisplayOut ' Stopped: ',$BVStopped -C 14,15 -L -G:$GuiSwitch }
		DisplayOut ' Elapsed Time: ',$StopWatchTime -C 14,15 -L -G:$GuiSwitch
	} Else {
		DisplayOut ' List of Service Done...' -C 14 -L -G:$GuiSwitch
		DisplayOut "`n If not Non-Dry Run/Dev Log " -C 14 -L -G:$GuiSwitch
		DisplayOut ' Changed: ',$BVChanged -C 14,15 -L -G:$GuiSwitch
		DisplayOut ' Already: ',$BVAlready -C 14,15 -L -G:$GuiSwitch
		DisplayOut ' Skipped: ',$BVSkipped -C 14,15 -L -G:$GuiSwitch
	}

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
			If([Windows.Forms.MessageBox]::Show("Thanks for using my script.`nIf you like this script please consider giving me a donation.`n`nWould you Consider giving a Donation?",'Thank You','YesNo','Question') -eq 'Yes'){ ClickedDonate }
		}
	}
	ServiceBAfun 'Services-After'
	If($DevLog -eq 1 -and $error.count -eq $ErrCount){ Write-Output $error | Out-File -LiteralPath $LogFile -Encoding Unicode -Append ;$ErrCount = $error.count }
	If($GuiSwitch) {
		DisplayOut "`n To exit you can close the GUI or PowerShell Window." 14 -G:$GuiSwitch
		GetCurrServices; RunDisableCheck
	} Else {
		AutomatedExitCheck 1
	}
}

Function ServiceCheck([String]$S_Name,[String]$S_Type) {
	If($CurrServices.Name -Contains $S_Name) {
		If($XboxService -eq 1 -and $XboxServiceArr -Contains $S_Name){ Return 'Xbox' }
		If($Skip_Services -Contains $S_Name){ Return 'Denied' }
		$C_Type = ($CurrServices.Where{$_.Name -eq $S_Name}).StartType
		If($S_Type -ne $C_Type) {
			If($S_Name -eq 'lfsvc' -And $C_Type -eq 'disabled' -And (Test-Path 'HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3')) {
				Remove-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3' -Recurse -Force
			} ElseIf($S_Name -eq 'NetTcpPortSharing') {
				If($NetTCP -Contains $CurrServices.Name){ Return 'Manual' } Return 'None'
			}
			Return $C_Type
		}
		Return 'Already'
	}
	Return 'None'
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
	$Pick = "$Pick".PadRight(28)
	While($LoadWebCSV -ne 'Out') {
		Error_Top_Display
		DisplayOut '|',' The File ','BlackViper.csv',$Pick,'|' -C 14,2,15,2,14 -L
		MenuBlankLine
		DisplayOut '|',' Do you want to download ','BlackViper.csv',' ?           ','|' -C 14,2,15,2,14 -L
		MenuBlankLine
		MenuLine
		$Invalid = ShowInvalid $Invalid
		$LoadWebCSV = Read-Host "`nDownload? (Y)es/(N)o"
		$LoadWebCSV = $LoadWebCSV.ToLower()
		If($LoadWebCSV -In 'y','yes') {
			DownloadFile $Service_Url $ServiceFilePath ;$LoadWebCSV = 'Out'
		} ElseIf($LoadWebCSV -In 'n','no') {
			DisplayOut 'For manual download save the following File: ' -C 2 -L
			DisplayOut 'https://github.com/madbomb122/BlackViperScript/raw/master/BlackViper.csv' -C 15 -L
		} Else {
			$Invalid = 1
		}
	}
	If($ErrorChoice -In 1..2){ [System.Collections.ArrayList]$Script:csv = Import-Csv -LiteralPath $ServiceFilePath }
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
	If([windows.forms.messagebox]::show($ErrMessage,'Error','YesNo','Error') -eq 'Yes'){
		DownloadFile $Service_Url $ServiceFilePath
		If($ErrorChoice -In 1..2){ [System.Collections.ArrayList]$Script:csv = Import-Csv -LiteralPath $ServiceFilePath }
		CheckBVcsv
	} Else {
		[Windows.Forms.MessageBox]::Show("To get The File 'BlackViper.csv' go to https://github.com/madbomb122/BlackViperScript to save it.`nWithout the file the script won't run",'Information','OK','Information') | Out-Null
		$Form.Close()
		Exit
	}
}

Function PreScriptCheck {
	If($RunScript -eq 0){ If($GuiSwitch){ $Form.Close() } ;Exit }
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

	If($Win10Ver -lt $MinVer -And $BuildCheck -ne 1) {
		If($EditionCheck -eq 'Fail'){ $Script:ErrorDi += ' & ' }
		$Script:ErrorDi += 'Build'
		$BuildCheck = 'Fail'
		$EBCount++
	}

	If($EBCount -ne 0) {
		$Script:ErrorDi += ' Check Failed'
		$EBCount=0
		Error_Top_Display
		DisplayOutLML " Script won't run due to the following problem(s)" 2 -L
		MenuBlankLine -L
		MenuBlankLineLog -L
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
			DisplayOutLML 'Please contact me with:' 2 -L
			DisplayOutLML ' 1. The Edition listed above' 2 -L
			DisplayOutLML ' 2. The SKU # listed above' 2 -L
			MenuBlankLine -L
			DisplayOutLML 'To skip use one of the following methods' 2 -L
			DisplayOut '|','  1. Run Script or bat file with ','-secp',' argument'.PadRight(14),'|' -C 14,2,15,2,14 -L
			DisplayOut '|','  1. Run Script or bat file with ','-sech',' argument'.PadRight(14),'|' -C 14,2,15,2,14 -L
			DisplayOut '|','  3. Change ','EditionCheck',' in script file'.PadRight(28),'|' -C 14,2,15,2,14 -L
			DisplayOut '|','  4. Change ','Skip_EditionCheck',' in bat file'.PadRight(23),'|' -C 14,2,15,2,14 -L
			MenuBlankLine -L
			MenuBlankLineLog -L
		}
		If($BuildCheck -eq 'Fail') {
			$EBCount++
			MenuBlankLine -L
			DisplayOutLML "$EBCount. Not a valid Build for this Script." 2 -L
			DisplayOutLML "Lowest Build Recommended - Creator's Update (1703)" 2 -L
			MenuBlankLine -L
			DisplayOut '|',' You are using Build: ',"$BuildVer".PadRight(30),'|' -C 14,2,15,14 -L
			DisplayOut '|',' You are using Version: ',"$Win10Ver".PadRight(28),'|' -C 14,2,15,14 -L
			MenuBlankLine -L
			DisplayOutLML 'To skip use one of the following methods' 2 -L
			DisplayOut '|','  1. Run Script or bat file with ','-sbc',' argument'.PadRight(15),'|' -C 14,2,15,2,14 -L
			DisplayOut '|','  2. Change ','BuildCheck',' in script file'.PadRight(30),'|' -C 14,2,15,2,14 -L
			DisplayOut '|','  3. Change ','Skip_BuildCheck',' in bat file'.PadRight(25),'|' -C 14,2,15,2,14 -L
			MenuBlankLineLog -L
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
			Error_Top_Display
			$SrvConFileLen = $ServiceFilePath.length
			If($SrvConFileLen -gt 42){ $SrvConFileLen = 42 }
			DisplayOut '|',' The File ',$ServiceFilePath,' is missing.'.PadRight(42-$ServiceFilePath),'|' -C 14,2,15,2,14 -L
			Error_Bottom
		}
		$ServiceVerCheck = 0
	} ElseIf($LoadServiceConfig -eq 2) {
		# This is supposed to be EMPTY
	} Else {
		$ServiceFilePath = $filebase + 'BlackViper.csv'
		If(!(Test-Path -LiteralPath $ServiceFilePath -PathType Leaf)) {
			If($ServiceVerCheck -eq 0) {
				If($ScriptLog -eq 1){ Write-Output "Missing File 'BlackViper.csv'" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append }
				If($GuiSwitch){ LoadWebCSVGUI 0 } Else{ LoadWebCSV 0 }
			} Else {
				If($ScriptLog -eq 1){ Write-Output "Downloading Missing File 'BlackViper.csv'" | Out-File -LiteralPath $LogFile -Encoding Unicode -Append }
				DownloadFile $Service_Url $ServiceFilePath
			}
			$ServiceVerCheck = 0
		}
	}
	If($LoadServiceConfig -ne 2){ [System.Collections.ArrayList]$Script:csv = Import-Csv -LiteralPath $ServiceFilePath }
	If($ScriptVerCheck -eq 1 -or $ServiceVerCheck -eq 1){ UpdateCheckAuto }
	If($LoadServiceConfig -ne 2){ CheckBVcsv ;$csv.RemoveAt(0) }
}

Function CheckBVcsv {
	$GenBy = $csv[0].'Def-Pro-Full'
	If($GenBy -ne 'GernetatedByMadBomb122' -and $GenBy -ne 'GeneratedByMadBomb122') {
		If($Automated -ne 1) {
			If($GuiSwitch){ LoadWebCSVGUI 1 } Else{ LoadWebCSV 1 }
		} Else {
			Error_Top_Display
			DisplayOut '|',' The File ','BlackViper.csv',' is Invalid or Corrupt.     ','|' -C 14,2,15,2,14 -L
			Error_Bottom
		}
	} ElseIf(!(Test-Path -LiteralPath $ServiceFilePath -PathType Leaf)) {
		If($GuiSwitch){
			[Windows.Forms.MessageBox]::Show("The File 'BlackViper.csv' is missing and couldn't be downloaded.`nFor Manual download go to https://github.com/madbomb122/BlackViperScript",'Information', 'OK','Information') | Out-Null
		} Else{
			$Script:ErrorDi = 'Missing File BlackViper.csv'
			Error_Top_Display
			DisplayOut '|',' The File ','BlackViper.csv'," is missing and couldn't    ",'|' -C 14,2,15,2,14 -L
			DisplayOutLML "be download for some reason." 2 -L
			Error_Bottom
		}
	}
	If($GuiSwitch){ $WPF_LoadServicesButton.IsEnabled = SetServiceVersion } Else{ SetServiceVersion | Out-Null }
}

Function GetArgs {
	For($i=0 ;$i -lt $PassedArg.Length ;$i++) {
		If($PassedArg[$i].StartsWith('-')) {
			$tmpS = $PassedArg[$i]
			If($tmpS -eq '-default'){ $Script:Black_Viper = 1 ;$Script:BV_ArgUsed = 2 }
			ElseIf($tmpS -eq '-safe'){ $Script:Black_Viper = 2 ;$Script:BV_ArgUsed = 2}
			ElseIf($tmpS -eq '-tweaked'){ If($IsLaptop -ne '-Lap'){ $Script:Black_Viper = 3 ;$Script:BV_ArgUsed = 2 } Else{ $Script:BV_ArgUsed = 1 } }
			ElseIf($tmpS -eq '-all'){ $Script:All_or_Min = '-full' }
			ElseIf($tmpS -eq '-min'){ $Script:All_or_Min = '-min' }
			ElseIf($tmpS -eq '-log'){ $Script:ScriptLog = 1 ;If(!($PassedArg[$i+1].StartsWith('-'))){ $Script:LogName = $PassedArg[$i+1] ;$i++ } }
			ElseIf($tmpS -eq '-logc'){ $Script:ScriptLog = 2 ;If(!($PassedArg[$i+1].StartsWith('-'))){ $Script:LogName = $PassedArg[$i+1] ;$i++ } } #To append to logfile (used for update)
			ElseIf($tmpS -eq '-lcsc'){ $Script:BV_ArgUsed = 3 ;$Script:LoadServiceConfig = 1 ;If(!($PassedArg[$i+1].StartsWith('-'))){ $Script:ServiceConfigFile = $PassedArg[$i+1] ;$i++ } }
			ElseIf($tmpS -eq '-bscc'){ $Script:BackupServiceConfig = 1 ;$Script:BackupServiceType = 1 }
			ElseIf($tmpS -eq '-bscr'){ $Script:BackupServiceConfig = 1 ;$Script:BackupServiceType = 0 }
			ElseIf($tmpS -eq '-bscb'){ $Script:BackupServiceConfig = 1 ;$Script:BackupServiceType = 2 }
			ElseIf($tmpS -eq '-baf'){ $Script:LogBeforeAfter = 1 }
			ElseIf($tmpS -eq '-snis'){ $Script:ShowNonInstalled = 1 }
			ElseIf($tmpS -eq '-sss'){ $Script:ShowSkipped = 1 }
			ElseIf($tmpS -eq '-sic'){ $Script:InternetCheck = 1 }
			ElseIf($tmpS -eq '-usc'){ $Script:ScriptVerCheck = 1 }
			ElseIf($tmpS -eq '-use'){ $Script:ServiceVerCheck = 1 }
			ElseIf($tmpS -eq '-auto'){ $Script:Automated = 1 ;$Script:AcceptToS = 'Accepted-Automated' }
			ElseIf($tmpS -eq '-atos'){ $Script:AcceptToS = 'Accepted' }
			ElseIf($tmpS -eq '-atosu'){ $Script:AcceptToS = 'Accepted' }
			ElseIf($tmpS -eq '-dry'){ $Script:DryRun = 1 ;$Script:ShowNonInstalled = 1 }
			ElseIf($tmpS -eq '-diag'){ $Script:Diagnostic = 1 ;$Script:Automated = 0 }
			ElseIf($tmpS -eq '-diagf'){ $Script:Diagnostic = 2 ;$Script:Automated = 0 ;$Script:ErrorDi = 'Forced Diag Output' }
			ElseIf($tmpS -eq '-devl'){ $Script:DevLog = 1 }
			ElseIf($tmpS -eq '-sbc'){ $Script:BuildCheck = 1 }
			ElseIf($tmpS -eq '-sech'){ $Script:EditionCheck = 'Home' }
			ElseIf($tmpS -eq '-sxb'){ $Script:XboxService = 1 }
			ElseIf($tmpS -In '-secp','-sec'){ $Script:EditionCheck = 'Pro' }
			ElseIf($tmpS -In '-help','-h'){ ShowHelp }
		}
	}
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
	DisplayOut '  -log ','            Makes a log file ','Script.log' -C 14,15,11
	DisplayOut '  -baf ','            Log File of Services Configuration Before and After the script' -C 14,15
	DisplayOut "`n--Backup Service Configuration--" -C 2
	DisplayOut '  -bscc ','           Backup Current Service Configuration, Csv File' -C 14,15
	DisplayOut '  -bscr ','           Backup Current Service Configuration, Reg File' -C 14,15
	DisplayOut '  -bscb ','           Backup Current Service Configuration, Csv and Reg File' -C 14,15
	DisplayOut "`n--Misc Switches--" -C 2
	DisplayOut '  -dry  ','           Runs the script and shows what services will be changed' -C 14,15
	DisplayOut '  -snis ','           Show not installed Services' -C 14,15
	DisplayOut '  -sss  ','           Show Skipped Services' -C 14,15
	DisplayOut "`n--AT YOUR OWN RISK Switches--" -C 13
	DisplayOut '  -secp ','           Skips Edition Check by Setting Edition as Pro' -C 14,15
	DisplayOut '  -sech ','           Skips Edition Check by Setting Edition as Home' -C 14,15
	DisplayOut '  -sbc  ','           Skips Build Check' -C 14,15
	DisplayOut "`n--Dev Switches--" -C 2
	DisplayOut '  -diag ','           Shows diagnostic information, Stops ','-auto' -C 14,15,14
	DisplayOut '  -diagf ','          Forced diagnostic information, Script does nothing else' -C 14,15
	AutomatedExitCheck 1
	Exit
}

Function StartScript {
	If(Test-Path -LiteralPath $SettingPath -PathType Leaf){ Import-Clixml -LiteralPath $SettingPath  | ForEach-Object { Set-Variable $_.Var $_.Val -Scope Script } }
	$Script:PCType = (Get-CimInstance -Class Win32_ComputerSystem).PCSystemType
	If($PCType -ne 2) {
		$Script:IsLaptop = '-Desk'
	} Else {
		$Script:IsLaptop = '-Lap'
		If($LaptopTweaked -ne 1 -and $Black_Viper -ge 2){ $Script:Black_Viper = 0 }
	}
	If($PassedArg.Length -gt 0){ GetArgs }

	$Script:WinSku = (Get-CimInstance Win32_OperatingSystem).OperatingSystemSKU
	# 48 = Pro, 49 = Pro N
	# 98 = Home N, 100 = Home (Single Language), 101 = Home

	$Script:FullWinEdition = (Get-CimInstance Win32_OperatingSystem).Caption
	$Script:WinEdition = $FullWinEdition.Split(' ')[-1]
	# Pro or Home

	# https://en.wikipedia.org/wiki/Windows_10_version_history
	$Script:BuildVer = [Environment]::OSVersion.Version.build

	$Script:MinVer = 1703
	$Script:Win10Ver = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion' -Name ReleaseID).ReleaseId
	# 1803 = April 2018 Update
	# 1709 = Fall Creators Update
	# 1703 = Creators Update
	# 1607 = Anniversary Update
	# 1511 = November Update (First Major Update)
	# 1507 = First Release

	$Skip_Services = @(
	'PimIndexMaintenanceSvc_',
	'DevicesFlowUserSvc_',
	'BcastDVRUserService_',
	'PrintWorkflowUserSvc_',
	'UserDataSvc_',
	'UnistoreSvc_',
	'WpnUserService_',
	'AppXSVC',
	'BrokerInfrastructure',
	'ClipSVC',
	'CoreMessagingRegistrar',
	'DcomLaunch',
	'EntAppSvc',
	'gpsvc',
	'LSM',
	'NgcSvc',
	'NgcCtnrSvc',
	'RpcSs',
	'RpcEptMapper',
	'sppsvc',
	'StateRepository',
	'SystemEventsBroker',
	'Schedule',
	'tiledatamodelsvc',
	'WdNisSvc',
	'WinDefend',
	'SecurityHealthService',
	'msiserver',
	'MpsSvc',
	'xbgm')

	For($i=0;$i -ne 7;$i++){ $Skip_Services[$i] = $Skip_Services[$i] + $ServiceEnd }
	If($Win10Ver -ge 1803){ $Skip_Services += 'UsoSvc' }
	GetCurrServices

	If($Diagnostic -eq 2) {
		Clear-Host
		DiagnosticCheck 1
		If($GuiSwitch){ $Form.Close() }
		Exit
	} ElseIf($BV_ArgUsed -eq 1) {
		CreateLog
		Error_Top_Display
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
		Error_Top_Display
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
# Options

$Script:AcceptToS = 0
# 0 = See ToS
# Anything Else = Accept ToS

$Script:EditionCheck = 0
# 0 = Check if Home or Pro Edition
# "Pro" = Set Edition as Pro (Needs "s)
# "Home" = Set Edition as Home (Needs "s)

$Script:BuildCheck = 0
# 0 = Check Build (Creator's Update Minimum)
# 1 = Skips this check

$Script:DryRun = 0
# 0 = Runs script normally
# 1 = Runs script but shows what will be changed

$Script:ShowAlreadySet = 1
# 0 = Don't Show Already set Services
# 1 = Show Already set Services

$Script:ShowNonInstalled = 0
# 0 = Don't Show Services not present
# 1 = Show Services not present

$Script:ShowSkipped = 0
# 0 = Don't Show Skipped Services
# 1 = Show Skipped Services

$Script:XboxService = 0
# 0 = Change Xbox Services
# 1 = Skip Change Xbox Services

$Script:StopDisabled = 0
# 0 = Dont change running status
# 1 = Disabled Services will change running status to Stop

#----- Log/Backup Items -----
$Script:ScriptLog = 0
# 0 = Don't make a log file
# 1 = Make a log file
# Will be script's directory named `Script.log` (default)

$Script:LogName = "Script-Log.log"
# Name of log file (you can change it)

$Script:LogBeforeAfter = 0
# 0 = Don't make a file of all the services before and after the script
# 1 = Make a file of all the services before and after the script
# Will be script's directory named "(ComputerName)-Services-Before.log" and "(ComputerName)-Services-Services-After.log"

$Script:BackupServiceConfig = 0
# 0 = Don't backup Your Current Service Configuration before services are changes
# 1 = Backup Your Current Service Configuration before services are changes (Configure type below)

$Script:BackupServiceType = 1
# 0 = ".reg" file that you can change w/o using script
# 1 = ".csv' file type that can be imported into script
# 2 = both the above types
# Will be in script's directory named "(ComputerName)-Service-Backup.(File Type)"

#--- Update Related Items ---
$Script:ScriptVerCheck = 0
# 0 = Skip Check for update of Script File
# 1 = Check for update of Script File
# Note: If found will Auto download and runs that, File name will be "BlackViper-Win10-Ver.(version#).ps1"

$Script:BatUpdateScriptFileName = 1
# 0-Don't Update Bat file with new script filename (if update is found)
# 1-Update Bat file with new script filename (if update is found)

$Script:ServiceVerCheck = 0
# 0 = Skip Check for update of Service File
# 1 = Check for update of Service File
# Note: If found will Auto download and current settings will be used

$Script:InternetCheck = 0
# 0 = Checks if you have Internet
# 1 = Bypass check if your pings are blocked
# Use if Pings are Blocked or can't ping GitHub.com

#---------- Dev Item --------
# Best not to use these unless asked to

$Script:Diagnostic = 0
# 0 = Doesn't show Shows diagnostic information
# 1 = Shows diagnostic information

$Script:DevLog = 0
# 0 = Doesn't make a Dev Log
# 1 = Makes a log files
# Devlog Contains -> Service Change, Bbefore & After for Services, and Diagnostic Info

$Script:ShowConsole = 0
# 0 = Hides console window (Only on stable release)
# 1 = Shows console window -Forced in Testing release

#--------------------------------------------------------------------------
# Do not change
StartScript
