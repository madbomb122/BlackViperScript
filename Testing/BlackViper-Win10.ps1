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
$Script_Version = '5.0'
$Minor_Version = '6'
$Script_Date = 'July-10-2018'
$Release_Type = 'Testing'
#$Release_Type = 'Stable'
##########

## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!                                            !!
## !!             SAFE TO EDIT ITEM              !!
## !!            AT BOTTOM OF SCRIPT             !!
## !!                                            !!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!                                            !!
## !!                  CAUTION                   !!
## !!        DO NOT EDIT PAST THIS POINT         !!
## !!                                            !!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

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

--Basic Switches--
 Switches       Description of Switch
  -atos          (Accepts ToS)
  -auto          (Implies -atos...Runs the script to be Automated.. Closes on - User Input, Errors, or End of Script)

--Service Configuration Switches--
  -default       (Runs the script with Services to Default Configuration)
  -safe          (Runs the script with Services to Black Viper's Safe Configuration)
  -tweaked       (Runs the script with Services to Black Viper's Tweaked Configuration)
  -lcsc File.csv (Loads Custom Service Configuration, File.csv = Name of your backup/custom file)

--Service Choice Switches--
  -all           (Every windows services will change)
  -min           (Just the services different from the default to safe/tweaked list)

--Update Switches--
  -usc           (Checks for Update to Script file before running)
  -use           (Checks for Update to Service file before running)
  -sic           (Skips Internet Check, if you can't ping GitHub.com for some reason)

--Log Switches--
  -log           (Makes a log file Script.log)
  -baf           (Log File of Services Configuration Before and After the script)

--AT YOUR OWN RISK Switches--
  -sec           (Skips Edition Check by Setting Edition as Pro)
  -secp           ^Same as Above
  -sech          (Skips Edition Check by Setting Edition as Home)
  -sbc           (Skips Build Check)

--Backup Service Configuration--
  -bscc          (Backup Current Service Configuration, Csv File)
  -bscr          (Backup Current Service Configuration, Reg File)
  -bscb          (Backup Current Service Configuration, Csv and Reg File)

--Misc Switches--
  -sxb           (Skips changes to all XBox Services)
  -dry           (Runs the script and shows what services will be changed)
  -diag          (Shows diagnostic information, Stops -auto)
  -snis          (Show not installed Services)
  -sss           (Show Skipped Services)
------------------------------------------------------------------------------#>
##########
# Pre-Script -Start
##########

Function AutomatedExitCheck([Int]$ExitBit) {
	If($Automated -ne 1){ Read-Host -Prompt "`nPress Any key to Close..." }
	If($ExitBit -eq 1){ If($GuiLoad -eq 1){ $Form.Close() } ;Exit }
}

$Script:WindowVersion = [Environment]::OSVersion.Version.Major
If($WindowVersion -ne 10) {
	Clear-Host
	Write-Host 'Sorry, this Script supports Windows 10 ONLY.' -ForegroundColor 'cyan' -BackgroundColor 'black'
	AutomatedExitCheck 1
}

If($Release_Type -eq 'Stable'){ $ErrorActionPreference = 'silentlycontinue' }

$Script:PassedArg = $args
$Script:filebase = $PSScriptRoot + '\'

If(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PassedArg" -Verb RunAs ;Exit
}

$URL_Base = 'https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/'
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

$colorsGUI = @(
'white',      #0
'yellow',     #1
'darkmagenta',#2
'darkblue',   #3
'darkcyan',   #4
'darkgray',   #5
'darkgreen',  #6
'cyan',       #2
'darkred',    #8
'darkyellow', #9
'gray',       #10
'green',      #11
'magenta',    #12
'red',        #13
'black',      #14
'blue')       #15

$ServicesTypeList = @(
'',         #0 -Skip Not Installed
'Disabled', #1
'Manual',   #2
'Automatic',#3 -Automatic
'Automatic')#4 -Automatic (Delayed)

$ServicesTypeFull = @(
'Skip',     #0
'Disabled', #1
'Manual',   #2
'Automatic',#3
'Automatic (Delayed)')#4

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
$Script:ErrCount = $error.count
$Script:CurrServices = Get-Service | Select-Object DisplayName, Name, StartType, Status

##########
# Pre-Script -End
##########
# Multi Use Functions -Start
##########

Function ThanksDonate {
	DisplayOut "`nThanks for using my script." 11 0
	DisplayOut 'If you like this script please consider giving me a donation.' 11 0
	DisplayOut "`nLink to donation:" 15 0
	DisplayOut 'https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/' 2 0
}

Function MenuBlankLineLog { DisplayOutMenu '|'.PadRight(51) 14 0 0 1 ;RightLineLog }
Function MenuLineLog { DisplayOutMenu '|'.PadRight(52,'-') 14 0 0 1 ;DisplayOut '|' 14 0 1 1 }
Function LeftLineLog { DisplayOutMenu '| ' 14 0 0 1 }
Function RightLineLog { DisplayOutMenu ' |' 14 0 1 1 }

Function MenuBlankLine { DisplayOutMenu '|'.PadRight(51) 14 0 0 0 ;RightLine }
Function MenuLine { DisplayOutMenu '|'.PadRight(52,'-') 14 0 0 0 ;DisplayOut '|' 14 0 1 0 }
Function LeftLine { DisplayOutMenu '| ' 14 0 0 0 }
Function RightLine { DisplayOutMenu ' |' 14 0 1 0 }

Function TOSLine([Int]$BC){ DisplayOutMenu '|'.PadRight(52,'-') $BC 0 0 ;DisplayOut '|' $BC 0 1 }
Function TOSBlankLine([Int]$BC){ DisplayOutMenu '|'.PadRight(52) $BC 0 0 ;DisplayOut '|' $BC 0 1 }

Function OpenWebsite([String]$Url){ [System.Diagnostics.Process]::Start($Url) }
Function DownloadFile([String]$Url,[String]$FilePath){ (New-Object System.Net.WebClient).DownloadFile($Url, $FilePath) }
Function ShowInvalid([Int]$InvalidA){ If($InvalidA -eq 1){ Write-Host "`nInvalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline } Return 0 }
Function GetAllServices { $Script:AllService = Get-CimInstance Win32_service | Select-Object Name, @{ Name = 'StartType' ;Expression = {$_.StartMode} } }

Function DisplayOutMenu([String]$TxtToDisplay,[Int]$TxtColor,[Int]$BGColor,[Int]$NewLine,[Int]$LogOut) {
	If($NewLine -eq 0) {
		If($ScriptLog -eq 1 -And $LogOut -eq 1){ Write-Output $TxtToDisplay 4>&1 | Out-File -Filepath $LogFile -NoNewline -Append }
		Write-Host -NoNewline $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
	} Else {
		If($ScriptLog -eq 1 -And $LogOut -eq 1){ Write-Output $TxtToDisplay 4>&1 | Out-File -Filepath $LogFile -Append }
		Write-Host $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
	}
}

Function DisplayOut([String]$TxtToDisplay,[Int]$TxtColor,[Int]$BGColor) {
	If($ScriptLog -eq 1){ Write-Output $TxtToDisplay 4>&1 | Out-File -Filepath $LogFile -Append }
	Write-Host $TxtToDisplay -ForegroundColor $colors[$TxtColor] -BackgroundColor $colors[$BGColor]
}

Function Error_Top_Display {
	Clear-Host
	DiagnosticCheck 0
	MenuLineLog
	LeftLineLog ;DisplayOutMenu '                      Error'.PadRight(49) 13 0 0 1 ;RightLineLog
	MenuLineLog
	MenuBlankLineLog
}

Function Error_Bottom {
	MenuBlankLineLog
	MenuLineLog
	If($Diagnostic -eq 1){ DiagnosticCheck 0 }
	AutomatedExitCheck 1
}

##########
# Multi Use Functions -End
##########
# TOS -Start
##########
Function TOSDisplay {
	Clear-Host
	$BorderColor = 14
	If($Release_Type -ne 'Stable') {
		$BorderColor = 15
		TOSLine 15
		DisplayOutMenu '|'.PadRight(20) 15 0 0 ;DisplayOutMenu 'Caution!!!'.PadRight(32) 13 0 0 ;DisplayOut '|' 15 0 1
		TOSBlankLine 15
		DisplayOutMenu '|' 15 0 0 ;DisplayOutMenu '        This script is still being tested.         ' 14 0 0 ;DisplayOut '|' 15 0 1
		DisplayOutMenu '|'.PadRight(16) 15 0 0 ;DisplayOutMenu 'USE AT YOUR OWN RISK.'.PadRight(36) 14 0 0 ;DisplayOut '|' 15 0 1
		TOSBlankLine 15
	}
	If($OSType -ne 64) {
		$BorderColor = 15
		TOSLine 15
		DisplayOutMenu '|'.PadRight(22) 15 0 0 ;DisplayOutMenu 'WARNING!!'.PadRight(30) 13 0 0 ;DisplayOut '|' 15 0 1
		TOSBlankLine 15
		DisplayOutMenu '|' 15 0 0 ;DisplayOutMenu '       These settings are ment for x64 Bit.'.PadRight(51) 14 0 0 ;DisplayOut '|' 15 0 1
		DisplayOutMenu '|'.PadRight(16) 15 0 0 ;DisplayOutMenu 'USE AT YOUR OWN RISK.'.PadRight(36) 14 0 0 ;DisplayOut '|' 15 0 1
		TOSBlankLine 15
	}
	TOSLine $BorderColor
	DisplayOutMenu '|'.PadRight(20) $BorderColor 0 0 ;DisplayOutMenu 'Terms of Use'.PadRight(32) 11 0 0 ;DisplayOut '|' $BorderColor 0 1
	TOSLine $BorderColor
	TOSBlankLine $BorderColor
	DisplayOutMenu '|' $BorderColor 0 0 ;DisplayOutMenu ' This program comes with ABSOLUTELY NO WARRANTY.   ' 2 0 0 ;DisplayOut '|' $BorderColor 0 1
	DisplayOutMenu '|' $BorderColor 0 0 ;DisplayOutMenu ' This is free software, and you are welcome to     ' 2 0 0 ;DisplayOut '|' $BorderColor 0 1
	DisplayOutMenu '|' $BorderColor 0 0 ;DisplayOutMenu ' redistribute it under certain conditions.'.PadRight(51) 2 0 0 ;DisplayOut '|' $BorderColor 0 1
	TOSBlankLine $BorderColor
	DisplayOutMenu '|' $BorderColor 0 0 ;DisplayOutMenu ' Read License file for full Terms.'.PadRight(51) 2 0 0 ;DisplayOut '|' $BorderColor 0 1
	TOSBlankLine $BorderColor
	TOSLine $BorderColor
}

Function TOS {
	While($TOS -ne 'Out') {
		TOSDisplay
		$Invalid = ShowInvalid $Invalid
		$TOS = Read-Host "`nDo you Accept? (Y)es/(N)o"
		Switch($TOS.ToLower()) {
			{$_ -eq 'n' -or $_ -eq 'no'} { Exit ;Break }
			{$_ -eq 'y' -or $_ -eq 'yes'} { $TOS = 'Out' ;TOSyes ;Break }
			Default { $Invalid = 1 ;Break }
		}
	} Return
}

Function TOSyes {
	$Script:AcceptToS = 'Accepted-Script'
	$Script:RunScript = 1
	If($LoadServiceConfig -eq 1) {
		Black_Viper_Set
	} ElseIf($Black_Viper -eq 0) {
		GuiStart
	} Else {
		Black_Viper_Set $Black_Viper $All_or_Min
	}
}

##########
# TOS -End
##########
# GUI -Start
##########

Function Update-Window {
	[cmdletBinding()]
	Param($Control,$Property,$Value,[Switch]$AppendContent)
	If($Property -eq 'Close'){ $syncHash.Window.Dispatcher.invoke([action]{$syncHash.Window.Close()},'Normal') ;Return }
	$form.Dispatcher.Invoke([Action]{ If($PSBoundParameters['AppendContent']){ $Control.AppendText($Value) } Else{ $Control.$Property = $Value } }, 'Normal')
}

Function OpenSaveDiaglog([Int]$SorO) {
	If($SorO -eq 0){ $SOFileDialog = New-Object System.Windows.Forms.OpenFileDialog } Else{ $SOFileDialog = New-Object System.Windows.Forms.SaveFileDialog }
	$SOFileDialog.InitialDirectory = $filebase
	If($SorO -ne 2){ $SOFileDialog.Filter = "CSV (*.csv)| *.csv" } Else{ $SOFileDialog.Filter = "Registration File (*.reg)| *.reg" }
	$SOFileDialog.ShowDialog()
	$SOFPath = $SOFileDialog.filename
	If($SOFPath) {
		Switch($SorO) {
			0 { $Script:ServiceConfigFile = $SOFPath ;$WPF_LoadFileTxtBox.Text = $ServiceConfigFile ;RunDisableCheck ;Break }
			1 { Save_Service $SOFPath ;Break }
			2 { RegistryServiceFile $SOFPath ;Break }
		}
	}
}

Function HideCustomSrvStuff {
	$WPF_LoadServicesButton.IsEnabled = $True
	$WPF_RadioAll.IsEnabled = $True
	$WPF_RadioMin.IsEnabled = $True
	ForEach($Var In $CNoteList){ $Var.Value.Visibility = 'Hidden' }
	$WPF_LoadFileTxtBox.Visibility = 'Hidden'
	$WPF_btnOpenFile.Visibility = 'Hidden'
}

Function SetServiceVersion {
	$TPath = $filebase + 'BlackViper.csv'
	If(Test-Path $TPath -PathType Leaf) {
		$TMP = Import-Csv $TPath
		$Script:ServiceVersion = $TMP[0].'Def-Home-Full'
		$Script:ServiceDate = $TMP[0].'Def-Home-Min'
		Return $True
	} Else {
		$Script:ServiceVersion = 'Missing File'
		$Script:ServiceDate = 'BlackViper.csv'
		Return $False
	}
}

Function ClickedDonate{ OpenWebsite 'https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/' ;$Script:ConsideredDonation = 'Yes' }

Function SaveSetting {
	ForEach($Var In $VarList) {
		If($Var.Value.IsChecked){ $SetValue = 1 } Else{ $SetValue = 0 }
		Set-Variable -Name ($Var.Name.Split('_')[1]) -Value $SetValue -Scope Script
	}
	If($WPF_RadioAll.IsChecked){ $Script:All_or_Min = '-full' } Else{ $Script:All_or_Min = '-min' }
	If($WPF_EditionCheckCB.IsChecked){ $Script:EditionCheck = $WPF_EditionConfig.Text }
	$Script:LogName = $WPF_LogNameInput.Text
	$Script:BackupServiceType = $WPF_BackupServiceType.SelectedIndex

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
	$Settings += [PSCustomObject] @{ Var = 'ScriptLog' ;Val = $ScriptLog }
	$Settings += [PSCustomObject] @{ Var = 'LogName' ;Val = $LogName }
	$Settings += [PSCustomObject] @{ Var = 'LogBeforeAfter' ;Val = $LogBeforeAfter }
	$Settings += [PSCustomObject] @{ Var = 'ShowConsole' ;Val = $ShowConsole }
	$Settings += [PSCustomObject] @{ Var = 'DevLog' ;Val = $DevLog }
	$Settings += [PSCustomObject] @{ Var = 'Diagnostic' ;Val = $Diagnostic }
	$Settings += [PSCustomObject] @{ Var = 'XboxService' ;Val = $XboxService }
	$Settings += [PSCustomObject] @{ Var = 'DryRun' ;Val = $DryRun }
	$Settings += [PSCustomObject] @{ Var = 'ShowNonInstalled' ;Val = $ShowNonInstalled }
	$Settings += [PSCustomObject] @{ Var = 'ShowAlreadySet' ;Val = $ShowAlreadySet }
	$Settings += [PSCustomObject] @{ Var = 'StopDisabled' ;Val = $StopDisabled }
	If($ConsideredDonation -eq 'Yes'){ $Settings += [PSCustomObject] @{ Var = 'ConsideredDonation' ;Val='Yes' } }
	$Settings | Export-Clixml $SettingPath
}

Function ShowConsole([Int]$Choice){ [Console.Window]::ShowWindow($ConsolePtr, $Choice) }#0 = Hide, 5 = Show

Function GuiStart {
	#Needed to Hide Console window
	Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("Kernel32.dll")] public static extern IntPtr GetConsoleWindow() ;[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
	$Script:ConsolePtr = [Console.Window]::GetConsoleWindow()

	Clear-Host
	DisplayOutMenu 'Preparing GUI, Please wait...' 15 0 1 0
	$Script:GuiLoad = 1

[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Black Viper Service Configuration Script By: MadBomb122" Height="375" Width="669" BorderBrush="Black" Background="White">
	<Window.Resources>
		<Style x:Key="SeparatorStyle1" TargetType="{x:Type Separator}">
			<Setter Property="SnapsToDevicePixels" Value="True"/>
			<Setter Property="Margin" Value="0,0,0,0"/>
			<Setter Property="Template">
				<Setter.Value> <ControlTemplate TargetType="{x:Type Separator}"><Border Height="24" SnapsToDevicePixels="True" Background="#FF4D4D4D" BorderBrush="#FF4D4D4D" BorderThickness="0,0,0,1"/></ControlTemplate></Setter.Value>
			</Setter>
		</Style>
		<Style TargetType="{x:Type ToolTip}"><Setter Property="Background" Value="#FFFFFFBF"/></Style>
	</Window.Resources>
	<Window.Effect><DropShadowEffect/></Window.Effect>
	<Grid>
		<Button Name="RunScriptButton" Content="Run Script" Margin="0,0,0,21" VerticalAlignment="Bottom" Height="20" FontWeight="Bold"/>
		<TextBox Name="Script_Ver_Txt" HorizontalAlignment="Left" Height="20" TextWrapping="Wrap" VerticalAlignment="Bottom" Width="330" IsEnabled="False" HorizontalContentAlignment="Center"/>
		<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="330,0,0,0" Stroke="Black" Width="1" Height="20" VerticalAlignment="Bottom"/>
		<TextBox Name="Service_Ver_Txt" HorizontalAlignment="Left" Height="20" Margin="331,0,0,0" TextWrapping="Wrap" VerticalAlignment="Bottom" Width="330" IsEnabled="False" HorizontalContentAlignment="Center"/>
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
					<TextBox Name="LoadFileTxtBox" HorizontalAlignment="Left" Height="50" Margin="5,171,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="461" IsReadOnly="True" Background="#FFECECEC"/>
					<Label Name="CustomNote3" Content="Config File: Browse for file" HorizontalAlignment="Left" Margin="76,139,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
					<Label Name="CustomNote2" Content="Custom Configuration" HorizontalAlignment="Left" Margin="164,116,0,0" VerticalAlignment="Top" Width="135" Height="26" FontWeight="Bold"/>
				</Grid>
			</TabItem>
			<TabItem Name="ServicesCB_Tab" Header="Services List" Margin="-2,0,2,0">
				<Grid Background="#FFE5E5E5">
					<DataGrid Name="dataGrid" AutoGenerateColumns="False" AlternationCount="2" HeadersVisibility="Column" Margin="-2,47,-2,-2" CanUserResizeRows="False" CanUserAddRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">
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
					<CheckBox Name="BatUpdateScriptFileName_CB" Content="Update Bat file with new Script file**" HorizontalAlignment="Left" Margin="239,110,0,0" VerticalAlignment="Top" Height="15" Width="214"/>
					<Button Name="CheckUpdateSerButton" Content="Services" HorizontalAlignment="Left" Margin="494,84,0,0" VerticalAlignment="Top" Width="109"/>
					<Button Name="CheckUpdateSrpButton" Content="Script*" HorizontalAlignment="Left" Margin="494,109,0,0" VerticalAlignment="Top" Width="109"/>
					<Button Name="CheckUpdateBothButton" Content="Services &amp; Script*" HorizontalAlignment="Left" Margin="494,134,0,0" VerticalAlignment="Top" Width="109"/>
					<CheckBox Name="ServiceUpdateCB" Content="Auto Service Update" HorizontalAlignment="Left" Margin="239,80,0,0" VerticalAlignment="Top" Height="15" Width="131"/>
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
					<CheckBox Name="DevLog_CB" Content="Dev Log" HorizontalAlignment="Left" Margin="7,184,0,0" VerticalAlignment="Top" Height="15" Width="174"/>
					<Label Content="SKIP CHECK AT YOUR OWN RISK!" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="409,-2,0,0" FontWeight="Bold"/>
					<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="176,0,0,0" Stroke="Black" Width="1" Height="58" VerticalAlignment="Top"/>
					<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="403,0,0,0" Stroke="Black" Width="1" Height="58" VerticalAlignment="Top"/>
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="-6,58,0,0" Stroke="Black" VerticalAlignment="Top"/>
					<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="229,59,0,0" Stroke="Black" Width="1" Height="160" VerticalAlignment="Top"/>
					<Label Content="Dev Options" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="2,145,0,0" FontWeight="Bold"/>
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="-6,148,0,0" Stroke="Black" VerticalAlignment="Top" HorizontalAlignment="Left" Width="235"/>
					<Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="459,59,0,0" Stroke="Black" Width="1"/>
					<Label Content="Check for Update Now for:" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="464,55,0,0" FontWeight="Bold"/>
					<CheckBox Name="ShowWindow" Content="Show Console Window" HorizontalAlignment="Left" Margin="7,199,0,0" VerticalAlignment="Top" Height="15" Width="144"/>
					<Label Content="*Wont remember Settings in&#xD;&#xA;'Service Options' or 'Services&#xD;&#xA;List' Tab" HorizontalAlignment="Left" Margin="464,157,0,0" VerticalAlignment="Top" FontWeight="Bold" Width="177" Height="61"/>
					<Rectangle Fill="#FFFFFFFF" Height="1" Margin="-6,218,0,0" Stroke="Black" VerticalAlignment="Top" HorizontalAlignment="Left" Width="465"/>
					<CheckBox Name="LaptopTweaked_CB" Content="Enable Tweak Setting on Laptop" HorizontalAlignment="Left" Margin="7,225,0,0" VerticalAlignment="Top" Height="15" Width="193"/>
					<Label Name="LaptopTweaked_txt" Content="*CAUTION: Use this with EXTREME CAUTION" HorizontalAlignment="Left" Margin="194,220,0,0" VerticalAlignment="Top" FontWeight="Bold" Width="263"/>
					<CheckBox Name="StopDisabled_CB" Content="Stop Disabled Services" HorizontalAlignment="Left" Margin="7,108,0,0" VerticalAlignment="Top" Height="15" Width="144"/>
				</Grid>
			</TabItem>
			<TabItem Name="ServiceChanges" Header="Service Changes" Margin="-2,0,2,0" Visibility="Hidden">
				<Grid Background="#FFE5E5E5">
					<ScrollViewer VerticalScrollBarVisibility="Visible"><TextBlock Name="ServiceListing" TextTrimming="CharacterEllipsis" Background="White"/></ScrollViewer>
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
			<MenuItem Name="BlackViperWSButton" Header="BlackViper's Website" Height="24" Width="130" Background="#FF3FDA62" FontWeight="Bold"/>
			<MenuItem Name="Madbomb122WSButton" Header="Madbomb122's GitHub" Height="24" Width="142" Background="Gold" FontWeight="Bold"/>
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

	$WPF_ServiceConfig.add_SelectionChanged({
		If(($WPF_ServiceConfig.SelectedIndex+1) -eq $BVCount) {
			$WPF_RadioAll.IsEnabled = $False
			$WPF_RadioMin.IsEnabled = $False
			ForEach($Var In $CNoteList){ $Var.Value.Visibility = 'Visible' }
			$WPF_LoadFileTxtBox.Visibility = 'Visible'
			$WPF_btnOpenFile.Visibility = 'Visible'
		} Else {
			HideCustomSrvStuff
		}
		RunDisableCheck
	})

	$WPF_RunScriptButton.Add_Click({
		SaveSetting
		$Script:RunScript = 1
		$Black_Viper = $WPF_ServiceConfig.SelectedIndex + 1
		If($Black_Viper -eq $BVCount) {
			If(!(Test-Path $ServiceConfigFile -PathType Leaf) -And $ServiceConfigFile -ne $null) {
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
			$WPF_RunScriptButton.content = 'Run Disabled while changing services.'
			$WPF_TabControl.Items[3].Visibility = 'Visible'
			$WPF_TabControl.Items[3].IsSelected = $True
			If($WPF_CustomBVCB.IsChecked) {
				$Script:LoadServiceConfig = 2
				[System.Collections.ArrayList]$Script:csvTemp = @()
				$ServiceCBList = $WPF_dataGrid.Items.Where({$_.checkboxChecked -eq $True})
				ForEach($item In $ServiceCBList){
					$BVTypeS = BVTypeNameToNumb $item.BVType
					$Script:csvTemp += [PSCustomObject] @{ ServiceName = $item.ServiceName ;StartType = $BVTypeS }
				}
				[System.Collections.ArrayList]$Script:csv = $Script:csvTemp
			}
#			$Form.Close()
			Black_Viper_Set $Black_Viper $All_or_Min
		} Else{
			RunDisableCheck
		}
	})

	[System.Windows.RoutedEventHandler]$DGclickEvent = {
		If($WPF_dataGrid.SelectedItem) {
			$TmpName = $WPF_dataGrid.SelectedItem.Name
			$DataGridListCust = $DataGridListCust | ForEach-Object {
				If($_.Name -eq $TmpName){ If($_.CurrType -eq $_.BVType){ $_.Matches = $True } Else{ $_.Matches = $False } $_ }
			}
			$WPF_dataGrid.ItemsSource = $DataGridListBlank
			$WPF_dataGrid.ItemsSource = $DataGridListCust
			$WPF_dataGrid.Items.Refresh()
		}
	}
	$WPF_dataGrid.AddHandler([System.Windows.Controls.CheckBox]::CheckedEvent,$DGclickEvent)
	$WPF_dataGrid.AddHandler([System.Windows.Controls.CheckBox]::UnCheckedEvent,$DGclickEvent)

	$WPF_EditionConfig.add_SelectionChanged({ RunDisableCheck })
	$WPF_BuildCheck_CB.Add_Click({ RunDisableCheck })
	$WPF_EditionCheckCB.Add_Click({ RunDisableCheck })

	$WPF_LaptopTweaked_CB.Add_Checked({
		If($WPF_ServiceConfig.Items.Count -eq 3) {
			$WPF_ServiceConfig.Items.RemoveAt(2)
			$WPF_ServiceConfig.Items.Add('Tweaked')
			$WPF_ServiceConfig.Items.Add('Custom Setting *')
			$Script:LaptopTweaked = 1
			$Script:BVCount++
		}
	})

	$WPF_LaptopTweaked_CB.Add_UnChecked({
		If($WPF_ServiceConfig.Items.Count -eq 4) {
			$WPF_ServiceConfig.Items.RemoveAt(2)
			$Script:LaptopTweaked = 0
			$Script:BVCount--
		}
	})

	$WPF_ShowWindow.Add_Checked({ ShowConsole 5 }) #5 = Show
	$WPF_ShowWindow.Add_UnChecked({ ShowConsole 0 }) #0 = Hide
	$WPF_ScriptLog_CB.Add_Checked({ $WPF_LogNameInput.IsEnabled = $True })
	$WPF_ScriptLog_CB.Add_UnChecked({ $WPF_LogNameInput.IsEnabled = $False })
	$WPF_CustomBVCB.Add_Checked({ CustomBVCBFun $True })
	$WPF_CustomBVCB.Add_UnChecked({ CustomBVCBFun $False })
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
	If($All_or_Min -eq '-full'){ $WPF_RadioAll.IsChecked = $True } Else{ $WPF_RadioMin.IsChecked = $True }
	$WPF_LogNameInput.Text = $LogName
	If($ScriptLog -eq 1) {
		$WPF_ScriptLog_CB.IsChecked = $True
		$WPF_LogNameInput.IsEnabled = $True
	}
	If($IsLaptop -eq '-Lap'){
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
	If($Release_Type -ne 'Stable'){ $WPF_ShowWindow.Visibility = 'Hidden' }

	$WPF_LoadFileTxtBox.Text = $ServiceConfigFile
	$WPF_LoadServicesButton.IsEnabled = SetServiceVersion
	$WPF_Script_Ver_Txt.Text = "Script Version: $Script_Version.$Minor_Version ($Script_Date) -$Release_Type"
	$WPF_Service_Ver_Txt.Text = "Service Version: $ServiceVersion ($ServiceDate)"
	$Script:ServiceImport = 1
	HideCustomSrvStuff
	RunDisableCheck
	Clear-Host
	DisplayOutMenu 'Displaying GUI Now' 14 0 1 0
	DisplayOutMenu "`nTo exit you can close the GUI or Powershell Window." 14 0 1 0
	If($Release_Type -eq 'Stable' -and $ShowConsole -eq 0){ ShowConsole 0 }
	$Form.ShowDialog() | Out-Null
	If($ShowConsole -eq 1){ $WPF_ShowWindow.IsChecked = $True }
	$WPF_RunScriptButton.IsEnabled = $True
}

Function CustomBVCBFun([Bool]$Choice) {
	$WPF_ACUcheckboxChecked.IsEnabled = $Choice
	If($Choice) {
		$Script:DataGridLCust = $true
		$WPF_SaveCustomSrvButton.content = 'Save Selection'
		$WPF_dataGrid.ItemsSource = $DataGridListCust
	} Else {
		$Script:DataGridLCust = $false
		$WPF_SaveCustomSrvButton.content = 'Save Current'
		$WPF_dataGrid.ItemsSource = $DataGridListOrig
	}
	$WPF_dataGrid.Items.Refresh()
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
		If(!($ServiceConfigFile) -or !(Test-Path $ServiceConfigFile -PathType Leaf)) {
			$Buttontxt = "Run Disabled, No Custom Service List File Selected or Doesn't exist."
		} Else {
			[System.Collections.ArrayList]$Tempcheck = Import-Csv $ServiceConfigFile
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
	$WPF_RunScriptButton.content = $Buttontxt
}

Function GenerateServices {
#	StartMode = StartType
#	Get-CimInstance Win32_service | Select-Object DisplayName, Name, StartMode, Description, PathName

	If($SrvCollected -ne 0){ $Script:ServiceInfo = Get-CimInstance Win32_service | Select-Object Name, Description, PathName ;$Script:SrvCollected = 1 }
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
	Switch($Black_Viper) {
		{$LoadServiceConfig -eq 1} { $Script:BVService = 'StartType' ;Break }
		1 { $Script:BVService = "Def-$WinEdition$FullMin" ;$BVSAlt = "Def-$WinEdition-Full" ;Break }
		2 { $Script:BVService = "Safe$IsLaptop$FullMin" ;$BVSAlt = "Safe$IsLaptop-Full" ;Break }
		3 { $Script:BVService = "Tweaked-Desk$FullMin" ;$BVSAlt = "Tweaked-Desk-Full" ;Break }
	}
	If($WPF_XboxService_CB.IsChecked){ $Script:XboxService = 1 } Else{ $Script:XboxService = 0 }
	If($ServiceImport -eq 1) {
		[System.Collections.ArrayList]$ServCB = Import-Csv $ServiceFilePath
		$ServiceImport = 0
	}
	[System.Collections.ArrayList]$Script:DataGridListOrig = @{}
	[System.Collections.ArrayList]$Script:DataGridListCust = @{}

	ForEach($item In $ServCB) {
		$ServiceName = $($item.ServiceName)
		If($ServiceName -Like '*_*'){ $ServiceName = Get-Service ($ServiceName.Split('_')[0] + '_*') | Select-Object Name }
		If($CurrServices.Name -Contains $ServiceName) {
			$tmp = $ServiceInfo -match $ServiceName
			$SrvDescription = $tmp.Description
			If($SrvDescription -Is [system.array]){ $SrvDescription = $SrvDescription[0] }
			$SrvPath = $tmp.PathName
			If($SrvPath -Is [system.array]){ $SrvPath = $SrvPath[0] }
			$ServiceTypeNum = $($item.$BVService)
			$ServiceCurrType = ($CurrServices.Where{$_.Name -eq $ServiceName}).StartType
			Switch($ServiceCurrType) {
				'Disabled' { $ServiceCurrType = 'Disabled' ;Break }
				'Manual' { $ServiceCurrType = 'Manual' ;Break }
				'Automatic' { $exists = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName\").DelayedAutostart ;If($exists -eq 1){ $ServiceCurrType = 'Automatic (Delayed)' } Else{ $ServiceCurrType = 'Automatic' } ;Break }
			}
			If($ServiceTypeNum -eq 0) {
				$checkbox = $False
				$ServiceTypeNum = $($item.$BVSAlt)
			} ElseIf($XboxService -eq 1 -and $XboxServiceArr -Contains $ServiceName) {
				$checkbox = $False
			} Else {
				$checkbox = $True
			}
			$ServiceType = $ServicesTypeList[$ServiceTypeNum]
			If($ServiceTypeNum -eq 4){ $ServiceType += ' (Delayed)' }
			If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
			$ServiceCommName = ($CurrServices.Where{$_.Name -eq $ServiceName}).DisplayName
			If($ServiceType -eq  $ServiceCurrType){ $Match = $True } Else{ $Match = $False }
			$Script:DataGridListOrig += [PSCustomObject] @{ checkboxChecked = $checkbox ;CName = $ServiceCommName ;ServiceName = $ServiceName ;CurrType = $ServiceCurrType ;BVType = $ServiceType ;StartType = $ServiceTypeNum ;ServiceTypeListDG = $ServicesTypeFull ;SrvDesc = $SrvDescription ;SrvPath = $SrvPath ;Matches = $Match }
			$Script:DataGridListCust += [PSCustomObject] @{ checkboxChecked = $checkbox ;CName = $ServiceCommName ;ServiceName = $ServiceName ;CurrType = $ServiceCurrType ;BVType = $ServiceType ;StartType = $ServiceTypeNum ;ServiceTypeListDG = $ServicesTypeFull ;SrvDesc = $SrvDescription ;SrvPath = $SrvPath ;Matches = $Match }
		}
	}
	$WPF_dataGrid.ItemsSource = $DataGridListOrig
	$WPF_dataGrid.Items.Refresh()
#	$DataGridListOrig | Select-Object checkboxChecked, CName, ServiceName, CurrType, BVType, SrvDesc, SrvPath | Out-GridView
#	$test = $DataGridListOrig | Select-Object checkboxChecked, CName, ServiceName, CurrType, BVType, SrvDesc, SrvPath | Out-GridView -PassThru

	If(!($ServicesGenerated)) {
		$WPF_ServiceClickLabel.Visibility = 'Hidden'
		$WPF_ServiceNote.Visibility = 'Visible'
		$WPF_CustomBVCB.Visibility = 'Visible'
		$WPF_SaveCustomSrvButton.Visibility = 'Visible'
		$WPF_SaveRegButton.Visibility = 'Visible'
		$WPF_TableLegend.Visibility = 'Visible'
		$WPF_Div1.Visibility = 'Visible'
		$WPF_LoadServicesButton.content = 'Reload'
		$Script:ServicesGenerated = $True
	}
}

Function BVTypeNameToNumb([String]$Name) {
	Switch($Name) {
		'Skip' { $Numb = 0 ;Break }
		'Disabled' { $Numb = 1 ;Break }
		'Manual' { $Numb = 2 ;Break }
		'Automatic' { $Numb = 3 ;Break }
		Default { $Numb = 4 ;Break }
	}
	Return $Numb
}

Function DGUCheckAll([Bool]$Choice) {
	ForEach($item in $DataGridListCust){ $item.checkboxChecked = $Choice }
	$WPF_dataGrid.Items.Refresh()
}

Function TBoxMessage([String]$Message,[Int]$ClrNum) {
	$WPF_ServiceListing.Dispatcher.invoke(
		[action]{
			$Run = New-Object System.Windows.Documents.Run
			$Run.Foreground = $colorsGUI[$ClrNum]
			$Run.Text = $message
			$WPF_ServiceListing.Inlines.Add($Run)
			$WPF_ServiceListing.Inlines.Add((New-Object System.Windows.Documents.LineBreak))
		},"Normal"
	)
	DisplayOut $Message $ClrNum 0
}

Function TBoxMessageNNL([String]$Message,[Int]$ClrNum) {
	$WPF_ServiceListing.Dispatcher.invoke(
		[action]{
			$Run = New-Object System.Windows.Documents.Run
			$Run.Foreground = $colorsGUI[$ClrNum]
			$Run.Text = $message
			$WPF_ServiceListing.Inlines.Add($Run)
		},"Normal"
	)
	DisplayOutMenu $Message $ClrNum 0 0 1
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
		LeftLineLog ;DisplayOutMenu 'No Internet connection detected or GitHub.com    ' 2 0 0 1 ;RightLineLog
		LeftLineLog ;DisplayOutMenu 'is currently down.'.PadRight(49) 2 0 0 1 ;RightLineLog
		LeftLineLog ;DisplayOutMenu 'Tested by pinging GitHub.com'.PadRight(49) 2 0 0 1 ;RightLineLog
		MenuBlankLineLog
		LeftLineLog ;DisplayOutMenu ' To skip use one of the following methods        ' 2 0 0 1 ;RightLineLog
		LeftLineLog ;DisplayOutMenu ' 1. Change ' 2 0 0 1 ;DisplayOutMenu 'InternetCheck' 15 0 0 1 ;DisplayOutMenu ' to ' 2 0 0 1 ;DisplayOutMenu '=1' 15 0 0 1 ;DisplayOutMenu ' in script file    ' 2 0 0 1 ;RightLineLog
		LeftLineLog ;DisplayOutMenu ' 2. Change ' 2 0 0 1 ;DisplayOutMenu 'InternetCheck' 15 0 0 1 ;DisplayOutMenu ' to ' 2 0 0 1 ;DisplayOutMenu '=no' 15 0 0 1 ;DisplayOutMenu ' in bat file      ' 2 0 0 1 ;RightLineLog
		LeftLineLog ;DisplayOutMenu ' 3. Run Script or Bat file with ' 2 0 0 1 ;DisplayOutMenu '-sic' 15 0 0 1 ;DisplayOutMenu ' argument    ' 2 0 0 1 ;RightLineLog
		MenuBlankLineLog
		MenuLineLog
		If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu 'The File ' 2 0 0 1 ;DisplayOutMenu 'BlackViper.csv' 15 0 0 1 ;DisplayOutMenu ' is missing and the script' 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu "can't run w/o it.".PadRight(49) 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			MenuLineLog
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
	Switch($USwitch) {
		0 {$Switch = 0 ;Break }
		1 {$SerCheck = 1 ;$SrpCheck = 0 ;Break }
		2 {$SerCheck = 0 ;$SrpCheck = 1 ;Break }
		3 {$SerCheck = 1 ;$SrpCheck = 1 ;Break }
	}

	If($SerCheck -eq 1 -or $ServiceVerCheck -eq 1) {
		$WebVersion = $CSV_Ver[1].Version
		If($ServiceVersion -eq 'Missing File'){ $ServVer = '0.0' } Else{ $ServVer = $ServiceVersion }
		If($LoadServiceConfig  -In 0..1 -And $WebVersion -gt $ServVer) {
			$Choice = 'Yes'
			If($Switch -eq 1) {
				If($ServiceVersion -eq 'Missing File') {
					$UpdateFound = 'Download Missing BlackViper.csv file?'
					$UpdateTitle = 'Missing File'
				} Else {
					$UpdateFound = 'Update Service File from $WebVersion to $ServVer ?'
					$UpdateTitle = 'Update Found'
				}
				$Choice = [windows.forms.messagebox]::show($UpdateFound,$UpdateTitle,'YesNo')
			}
			If($Choice -eq 'Yes') {
				If($ScriptLog -eq 1){ Write-Output "Downloading update for 'BlackViper.csv'" | Out-File -Filepath $LogFile }
				DownloadFile $Service_Url $ServiceFilePath
				If($LoadServiceConfig -ne 2){ [System.Collections.ArrayList]$Script:csv = Import-Csv $ServiceFilePath }
			} ElseIf($SrpCheck -ne 1) {
				$Switch = 0
			}
		} ElseIf($Switch -eq 1) {
			$Message = 'No Service update Found.'
		}
	}
	If($SrpCheck -eq 1 -or $ScriptVerCheck -eq 1) {
		If($Release_Type -eq 'Stable'){ $CSVLine = 0 } Else{ $CSVLine = 2 }
		$WebScriptVer = $CSV_Ver[$CSVLine].Version
		$WebScriptMinorVer =  $CSV_Ver[$CSVLine].MinorVersion
		If(($WebScriptVer -gt $Script_Version) -or ($WebScriptVer -eq $Script_Version -And $WebScriptMinorVer -gt $Minor_Version)){
			$Choice = 'Yes'
			If($Switch -eq 1){ $Choice = [windows.forms.messagebox]::show("Update Script File from $Script_Version.$Minor_Version to $WebScriptVer.$WebScriptMinorVer ?",'Update Found','YesNo') }
			If($Choice -eq 'Yes'){ ScriptUpdateFun } ElseIf($Message -eq ''){ $Switch = 0 }
		} ElseIf($Switch -eq 1) {
			If($Message -eq ''){ $Message = 'No Script update Found.' } Else{ $Message = 'Congrats you have the latest Service and Script version.' }
		}
	}
	If($Switch -eq 1){ [windows.forms.messagebox]::show($Message,'Update','OK') }
}

Function UpdateDisplay([String]$FullVer,[String]$DFilename) {
	Clear-Host
	MenuLineLog
	LeftLineLog ;DisplayOutMenu '                  Update Found!'.PadRight(49) 13 0 0 1 ;RightLineLog
	MenuLineLog
	MenuBlankLineLog
	LeftLineLog ;DisplayOutMenu 'Downloading version ' 15 0 0 1 ;DisplayOutMenu $FullVer.PadRight(29) 11 0 0 1 ;RightLineLog
	LeftLineLog ;DisplayOutMenu 'Will run ' 15 0 0 1 ;DisplayOutMenu $DFilename.PadRight(40) 11 0 0 1 ;RightLineLog
	LeftLineLog ;DisplayOutMenu 'after download is complete.'.PadRight(49) 2 0 0 1 ;RightLineLog
	MenuBlankLineLog
	MenuLineLog
}

Function ScriptUpdateFun {
	$FullVer = "$WebScriptVer.$WebScriptMinorVer"
	$UpdateFile = $filebase + 'Update.bat'
	$UpArg = ''
	If($GuiLoad -ne 1) {
		Switch($Black_Viper) {
			1 { $UpArg += '-default ' ;Break }
			2 { $UpArg += '-safe ' ;Break }
			3 { $UpArg += '-tweaked ' ;Break }
		}
		Switch($LoadServiceConfig) {
			1 { $UpArg += "-lcsc $ServiceConfigFile " ;Break }
			2 { $TempSrv = $Env:Temp + '\TempSrv.csv' ;$Script:csv | Export-Csv -LiteralPath $TempSrv -Encoding 'unicode' -Force -Delimiter ',' ;$UpArg += "-lcsc $TempSrv " ;Break }
		}
		If($Automated -eq 1){ $UpArg += '-auto ' }
	}
	Switch($EditionCheck) {
		'Home' { $UpArg += '-sech ' ;Break }
		'Pro' { $UpArg += '-secp ' ;Break }
	}
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
	If($All_or_Min -eq '-full'){ $UpArg += '-all ' } Else{ $UpArg += '-min ' }
	If($XboxService -eq 1){ $UpArg += '-sxb ' }
	If($ShowNonInstalled -eq 1){ $UpArg += '-snis ' }
	If($BackupServiceConfig -eq 1) {
		Switch($BackupServiceType) {
			0 { $UpArg += '-bscr ' ;Break }
			1 { $UpArg += '-bscc ' ;Break }
			2 { $UpArg += '-bscb ' ;Break }
		}
	}

	If(Test-Path $UpdateFile -PathType Leaf) {
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
			If(Test-Path $BatFile -PathType Leaf) {
				(Get-Content -LiteralPath $BatFile) | Foreach-Object {$_ -replace "Set Script_File=.*?$" , "Set Script_File=$DFilename"} | Set-Content -LiteralPath $BatFile -Force
				MenuBlankLineLog
				LeftLineLog ;DisplayOutMenu ' Updated bat file with new script file name.     ' 13 0 0 1 ;RightLineLog
				MenuBlankLineLog
				MenuLineLog
			}
		}
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$WebScriptFilePath`" $UpArg" -Verb RunAs
	}
	If($GuiLoad -eq 1){ $Form.Close() }
	Exit
}

##########
# Update Functions -End
##########
# Log/Backup Functions -Start
##########

Function ServiceBAfun([String]$ServiceBA) {
	If($LogBeforeAfter -eq 1) {
		$ServiceBAFile = "$filebase$Env:computername-$ServiceBA.log"
		If($ServiceBA -eq 'Services-Before'){ $CurrServices | Out-File $ServiceBAFile } Else{ Get-Service | Select-Object DisplayName, StartType | Out-File $ServiceBAFile }
	} ElseIf($LogBeforeAfter -eq 2) {
		If($ServiceBA -eq 'Services-Before'){ $TMPServices = $CurrServices } Else{ $TMPServices = Get-Service | Select-Object DisplayName, Name, StartType }
		Write-Output "`n$ServiceBA -Start" 4>&1 | Out-File -Filepath $LogFile -Append
		Write-Output '-------------------------------------' 4>&1 | Out-File -Filepath $LogFile -Append
		Write-Output $TMPServices 4>&1 | Out-File -Filepath $LogFile -Append
		Write-Output '-------------------------------------' 4>&1 | Out-File -Filepath $LogFile -Append
		Write-Output "$ServiceBA -End`n" 4>&1 | Out-File -Filepath $LogFile -Append
	}
}

Function Save_Service([String]$SavePath) {
	$ServiceSavePath = $filebase + $Env:computername
	$SaveService = @()

	If($WPF_CustomBVCB.IsChecked) {
		$ServiceSavePath += '-Custom-Service.csv'
		$ServiceCBList = $WPF_dataGrid.Items.Where({$_.checkboxChecked -eq $True})
		ForEach($item In $ServiceCBList) {
			$ServiceName = $item.ServiceName
			$BVTypeS = BVTypeNameToNumb $item.BVType
			If($ServiceName -Like "*_$ServiceEnd"){ $ServiceName = $ServiceName.Split('_')[0] + '_?????' }
			$SaveService += [PSCustomObject] @{ ServiceName = $ServiceName ;StartType = $BVTypeS }
		}
	} Else {
		If($AllService -eq $null) {
			$ServiceSavePath += '-Service-Backup.csv'
			GetAllServices
		} Else {
			$ServiceSavePath += '-Custom-Service.csv'
		}
		$SaveService = GenerateSaveService
	}
	If($SavePath -ne $null){ $ServiceSavePath = $SavePath}
	$SaveService | Export-Csv -LiteralPath $ServiceSavePath -encoding 'unicode' -force -Delimiter ','
	If($SavePath -ne $null){ [Windows.Forms.MessageBox]::Show("File saved as '$SavePath'",'File Saved', 'OK') | Out-Null }
}

Function Save_ServiceBackup {
	$ServiceSavePath = $filebase + $Env:computername
	$SaveService = @()
	$ServiceSavePath += '-Service-Backup.csv'
	If($AllService -eq $null){ GetAllServices }
	$SaveService = GenerateSaveService
	$SaveService | Export-Csv -LiteralPath $ServiceSavePath -encoding 'unicode' -force -Delimiter ','
}

Function GenerateSaveService {
	$TMPServiceL = @()
	ForEach($Service In $AllService) {
		$ServiceName = $Service.Name
		If(!($Skip_Services -Contains $ServiceName)) {
			Switch($($Service.StartType)) {
				'Disabled' { $StartType = 1 ;Break }
				'Manual' { $StartType = 2 ;Break }
				'Automatic' { $exists = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName\").DelayedAutostart ;If($exists -eq 1){ $StartType = 4 } Else{ $StartType = 3 } ;Break }
				Default { $StartType = "$($Service.StartType)" ;Break }
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
	Write-Output "Windows Registry Editor Version 5.00`n" | Out-File -Filepath $TempFP
	ForEach($Service In $AllService) {
		$ServiceName = $Service.Name
		If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
		If(!($Skip_Services -Contains $ServiceName)) {
			Switch($($Service.StartType)) {
				'Disabled' { $ServiceTypeNum = 4 ;Break }
				'Manual' { $ServiceTypeNum = 3 ;Break }
				'Automatic' { $ServiceTypeNum = 2 ;Break }
			}
			$Num = '"Start"=dword:0000000' + $ServiceTypeNum
			Write-Output "[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$ServiceName]" | Out-File -Filepath $TempFP -Append
			Write-Output $Num | Out-File -Filepath $TempFP -Append
			If($ServiceTypeNum -eq 2) {
				$exists = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName\").DelayedAutostart
				If($exists -eq 1){ Write-Output '"DelayedAutostart"=dword:00000001' | Out-File -Filepath $TempFP -Append }
			}
			Write-Output '' | Out-File -Filepath $TempFP -Append
		}
	}
}

Function GenerateRegistryCustom([String]$TempFP) {
	$ServiceCBList = $WPF_dataGrid.Items.Where({$_.checkboxChecked -eq $True})
	Write-Output "Windows Registry Editor Version 5.00`n" | Out-File -Filepath $TempFP
	ForEach($item In $ServiceCBList) {
		$ServiceName = $item.ServiceName
		$ServiceTypeNum = BVTypeNameToNumb $item.BVType
		If($ServiceTypeNum -ne 0) {
			If($ServiceName -Like '*_*'){ $ServiceName = Get-Service ($ServiceName.Split('_')[0] + '_*') | Select-Object Name }
			If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
			If(!($Skip_Services -Contains $ServiceName)) {
				$Num = '"Start"=dword:0000000' + $ServicesRegTypeList[$ServiceTypeNum]
				Write-Output "[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$ServiceName]" | Out-File -Filepath $TempFP -Append
				Write-Output $Num | Out-File -Filepath $TempFP -Append
				If($ServiceTypeNum -eq 4){ Write-Output '"DelayedAutostart"=dword:00000001' | Out-File -Filepath $TempFP -Append }
				Write-Output '' | Out-File -Filepath $TempFP -Append
			}
		}
	}
}

Function CreateLog {
	If($DevLog -eq 1) {
		$Script:ScriptLog = 1
		$Script:LogName = 'Dev-Log.log'
		$Script:Diagnostic = 1
		$Script:Automated = 0
		$Script:LogBeforeAfter = 2
		$Script:DryRun = 1
		$Script:AcceptToS = 'Accepted-Dev'
		$Script:ShowNonInstalled = 1
		$Script:ShowSkipped = 1
		$Script:ShowAlreadySet = 1
	}
	If($ScriptLog -ne 0) {
		$Script:LogFile = $filebase + $LogName
		$Time = Get-Date -Format g
		If($ScriptLog -eq 2) {
			Write-Output 'Updated Script File running' 4>&1 | Out-File -Filepath $LogFile -NoNewline -Append
			Write-Output "--Start of Log ($Time)--" | Out-File -Filepath $LogFile -NoNewline -Append
			$ScriptLog = 1
		} Else{
			Write-Output "--Start of Log ($Time)--" | Out-File -Filepath $LogFile
		}
	}
	$Script:LogStarted = 1
}

Function DiagnosticCheck([Int]$Bypass) {
	If($Release_Type -ne 'Stable' -or $Bypass -eq 1 -or $Diagnostic -eq 1) {
		DisplayOutMenu ' Diagnostic Output' 15 0 1 1
		DisplayOutMenu ' Some items may be blank' 15 0 1 1
		DisplayOutMenu ' --------Start--------' 15 0 1 1
		DisplayOutMenu " Script Version = $Script_Version" 15 0 1 1
		DisplayOutMenu " Script Minor Version = $Minor_Version" 15 0 1 1
		DisplayOutMenu " Release Type = $Release_Type" 15 0 1 1
		DisplayOutMenu " Services Version = $ServiceVersion" 15 0 1 1
		DisplayOutMenu " Error = $ErrorDi" 13 0 1 1
		DisplayOutMenu " Window = $WindowVersion" 15 0 1 1
		DisplayOutMenu " Edition = $FullWinEdition" 15 0 1 1
		DisplayOutMenu " Edition SKU# = $WinSku" 15 0 1 1
		DisplayOutMenu " Build = $BuildVer" 15 0 1 1
		DisplayOutMenu " Version = $Win10Ver" 15 0 1 1
		DisplayOutMenu " PC Type = $PCType" 15 0 1 1
		DisplayOutMenu " Desktop/Laptop = $IsLaptop" 15 0 1 1
		DisplayOutMenu " ServiceConfig = $Black_Viper" 15 0 1 1
		DisplayOutMenu " All/Min = $All_or_Min" 15 0 1 1
		DisplayOutMenu " ToS = $AcceptToS" 15 0 1 1
		DisplayOutMenu " Automated = $Automated" 15 0 1 1
		DisplayOutMenu " ScriptVerCheck = $ScriptVerCheck" 15 0 1 1
		DisplayOutMenu " ServiceVerCheck = $ServiceVerCheck" 15 0 1 1
		DisplayOutMenu " InternetCheck = $InternetCheck" 15 0 1 1
		DisplayOutMenu " ShowAlreadySet = $ShowAlreadySet" 15 0 1 1
		DisplayOutMenu " ShowNonInstalled = $ShowNonInstalled" 15 0 1 1
		DisplayOutMenu " ShowSkipped = $ShowSkipped" 15 0 1 1
		DisplayOutMenu " EditionCheck = $EditionCheck" 15 0 1 1
		DisplayOutMenu " BuildCheck = $BuildCheck" 15 0 1 1
		DisplayOutMenu " Args = $PassedArg" 15 0 1 1
		DisplayOutMenu " ---------End---------`n" 15 0 1 1
	}
}

##########
# Log/Backup Functions -End
##########
# Service Change Functions -Start
##########

Function Black_Viper_Set([Int]$BVOpt,[String]$FullMin) {
	PreScriptCheck
	Switch($BVOpt) {
		{$LoadServiceConfig -In 1..2} { $SrvSetting = 'Custom' ;$ServiceSetOpt = 'StartType' ;Break }
		1 { $SrvSetting = 'Default' ;$ServiceSetOpt = "Def-$WinEdition$FullMin" ;Break }
		2 { $SrvSetting = 'Safe' ;$ServiceSetOpt = "Safe$IsLaptop$FullMin" ;Break }
		3 { $SrvSetting = 'Tweaked' ;$ServiceSetOpt = "Tweaked-Desk$FullMin" ;Break }
	}
	If($GuiLoad -eq 1){ ServiceSetGUI $ServiceSetOpt $SrvSetting } Else{ ServiceSet $ServiceSetOpt $SrvSetting }
}

Function ServiceSet([String]$BVService,[String]$BVSet) {
	Clear-Host
	If($LogBeforeAfter -eq 2){ DiagnosticCheck 1 }
	ServiceBAfun 'Services-Before'
	If($DryRun -ne 1){ DisplayOut 'Changing Service Please wait...' 14 0 } Else{ DisplayOut 'List of Service that would be changed on Non-Dry Run...' 14 0 }
	DisplayOutMenu 'Service Setting: ' 14 0 0 1 ;DisplayOutMenu $BVSet 15 0 1 1
	DisplayOut 'Service_Name - Current -> Change_To' 14 0
	DisplayOut ''.PadRight(40,'-') 14 0
	ForEach($item In $csv) {
		$ServiceTypeNum = $($item.$BVService)
		$ServiceName = $($item.ServiceName)
		$ServiceCommName = ($CurrServices.Where{$_.Name -eq $ServiceName}).DisplayName
		If($ServiceTypeNum -eq 0 -And $ShowSkipped -eq 1) {
			If($ServiceCommName -ne $null){ $DispTemp = "Skipping $ServiceCommName ($ServiceName)" } Else{ $DispTemp = "Skipping $ServiceName" }
			DisplayOut $DispTemp  14 0
		} ElseIf($ServiceTypeNum -ne 0 -and $ServiceTypeNum -In 1..4) {
			If($ServiceName -Like '*_*'){ $ServiceName = Get-Service ($ServiceName.Split('_')[0] + '_*') | Select-Object Name }
			$ServiceType = $ServicesTypeList[$ServiceTypeNum]
			$ServiceCurrType = ServiceCheck $ServiceName $ServiceType
			If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
			If($ServicesTypeList -Contains $ServiceCurrType) {
				$DispTemp = "$ServiceCommName ($ServiceName) - $ServiceCurrType -> $ServiceType"
				If($DryRun -ne 1){ Set-Service $ServiceName -StartupType $ServiceType }
				If($ServiceTypeNum -eq 4) {
					$DispTemp += ' (Delayed)'
					If($DryRun -ne 1){ Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\$ServiceName\" -Name 'DelayedAutostart' -Type DWord -Value 1 }
				}
				If($StopDisabled -eq 1 -and $ServiceTypeNum -eq 1){
					If(($CurrServices.Where{$_.Name -eq $ServiceName}).Status -eq 'Running') {
						Stop-Service $ServiceName
						$DispTemp += ', Stopping Service'
					} Else {
						$DispTemp += ', Already Stopped'
					}
				}
				DisplayOut $DispTemp 11 0
			} ElseIf($ServiceCurrType -eq 'Already' -And $ShowAlreadySet -eq 1) {
				$DispTemp = "$ServiceCommName ($ServiceName) is already $ServiceType"
				If($ServiceTypeNum -eq 4){ $DispTemp += ' (Delayed)' }
				DisplayOut $DispTemp 15 0
			} ElseIf($ServiceCurrType -eq $False -And $ShowNonInstalled -eq 1) {
				DisplayOut "No service with name $ServiceName"  13 0
			} ElseIf($ServiceCurrType -eq 'Xbox') {
				DisplayOut "$ServiceCommName ($ServiceName) is an Xbox Service and will be skipped" 2 0
			} ElseIf($ServiceCurrType -eq 'Denied' -and $Release_Type -eq 'Testing') {
				DisplayOut "$ServiceCommName ($ServiceName) can't be changed." 14 0
			}
		} ElseIf($ServiceTypeNum -NotIn 1..4 -and $ServiceTypeNum -ne 0) {
			DisplayOut "Error: $ServiceName does not have a valid Setting." 13 0
		}
	}
	DisplayOut ''.PadRight(40,'-') 14 0

	If($DryRun -ne 1){ DisplayOut 'Service Changed...' 14 0 } Else{ DisplayOut 'List of Service Done...' 14 0 }
	ThanksDonate
	If($BackupServiceConfig -eq 1){
		Switch($BackupServiceType) {
			1 { DisplayOut 'Backup of Services Saved as CSV file in script directory.' 14 0 ;Break }
			0 { DisplayOut 'Backup of Services Saved as REG file in script directory.' 14 0 ;Break }
			2 { DisplayOut 'Backup of Services Saved as CSV and REG file in script directory.' 14 0 ;Break }
		}
	}
	ServiceBAfun 'Services-After'
	If($DevLog -eq 1 -and $error.count -gt $ErrCount){ Write-Output $error 4>&1 | Out-File -Filepath $LogFile -NoNewline -Append }
	AutomatedExitCheck 1
}

Function ServiceSetGUI([String]$BVService,[String]$BVSet) {
	Clear-Host
	If($LogBeforeAfter -eq 2){ DiagnosticCheck 1 }
	ServiceBAfun 'Services-Before'
	$WPF_ServiceListing.text = ''
	If($DryRun -ne 1){ TBoxMessage 'Changing Service Please wait...' 14 } Else{ TBoxMessage 'List of Service that would be changed on Non-Dry Run...' 14 }
	TBoxMessageNNL 'Service Setting: ' 14 ;TBoxMessage $BVSet 15
	TBoxMessage 'Service_Name - Current -> Change_To' 14
	TBoxMessage ''.PadRight(40,'-') 14
	ForEach($item In $csv) {
		$ServiceTypeNum = $($item.$BVService)
		$ServiceName = $($item.ServiceName)
		$ServiceCommName = ($CurrServices.Where{$_.Name -eq $ServiceName}).DisplayName
		If($ServiceTypeNum -eq 0 -And $ShowSkipped -eq 1) {
			If($ServiceCommName -ne $null){ $DispTemp = "Skipping $ServiceCommName ($ServiceName)" } Else{ $DispTemp = "Skipping $ServiceName" }
			TBoxMessage $DispTemp  14
		} ElseIf($ServiceTypeNum -ne 0 -and $ServiceTypeNum -In 1..4) {
			If($ServiceName -Like '*_*'){ $ServiceName = Get-Service ($ServiceName.Split('_')[0] + '_*') | Select-Object Name }
			$ServiceType = $ServicesTypeList[$ServiceTypeNum]
			$ServiceCurrType = ServiceCheck $ServiceName $ServiceType
			If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
			If($ServicesTypeList -Contains $ServiceCurrType) {
				$DispTemp = "$ServiceCommName ($ServiceName) - $ServiceCurrType -> $ServiceType"
				If($DryRun -ne 1){ Set-Service $ServiceName -StartupType $ServiceType }
				If($ServiceTypeNum -eq 4) {
					$DispTemp += ' (Delayed)'
					If($DryRun -ne 1){ Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\$ServiceName\" -Name 'DelayedAutostart' -Type DWord -Value 1 }
				}
				If($StopDisabled -eq 1 -and $ServiceTypeNum -eq 1){
					If(($CurrServices.Where{$_.Name -eq $ServiceName}).Status -eq 'Running') {
						Stop-Service $ServiceName
						$DispTemp += ', Stopping Service'
					} Else {
						$DispTemp += ', Already Stopped'
					}
				}
				TBoxMessage $DispTemp 11
			} ElseIf($ServiceCurrType -eq 'Already' -And $ShowAlreadySet -eq 1) {
				$DispTemp = "$ServiceCommName ($ServiceName) is already $ServiceType"
				If($ServiceTypeNum -eq 4){ $DispTemp += ' (Delayed)' }
				TBoxMessage $DispTemp 15
			} ElseIf($ServiceCurrType -eq $False -And $ShowNonInstalled -eq 1) {
				TBoxMessage "No service with name $ServiceName" 13
			} ElseIf($ServiceCurrType -eq 'Xbox') {
				TBoxMessage "$ServiceCommName ($ServiceName) is an Xbox Service and will be skipped" 2
			} ElseIf($ServiceCurrType -eq 'Denied' -and $Release_Type -eq 'Testing') {
				TBoxMessage "$ServiceCommName ($ServiceName) can't be changed." 14
			}
		} ElseIf($ServiceTypeNum -NotIn 1..4 -and $ServiceTypeNum -ne 0) {
			TBoxMessage "Error: $ServiceName does not have a valid Setting." 13
		}
	}
	TBoxMessage ''.PadRight(40,'-') 14
	If($DryRun -ne 1){ TBoxMessage 'Service Changed...' 14 } Else{ TBoxMessage 'List of Service Done...' 14 }
	If($BackupServiceConfig -eq 1){
		Switch($BackupServiceType) {
			1 { TBoxMessage 'Backup of Services Saved as CSV file in script directory.' 14 ;Break }
			0 { TBoxMessage 'Backup of Services Saved as REG file in script directory.' 14 ;Break }
			2 { TBoxMessage 'Backup of Services Saved as CSV and REG file in script directory.' 14 ;Break }
		}
	}
	ServiceBAfun 'Services-After'
	TBoxMessage "`nTo exit you can close the GUI or Powershell Window." 14
	ThanksDonate
	If($ConsideredDonation -ne 'Yes'){
		If([Windows.Forms.MessageBox]::Show("Thanks for using my script.`nIf you like this script please consider giving me a donation.`n`nWould you Consider giving a Donation?",'Thank You','YesNo','Question') -eq 'Yes'){ ClickedDonate }
	}
	$Script:CurrServices = Get-Service | Select-Object DisplayName, Name, StartType, Status
	RunDisableCheck
	If($DevLog -eq 1 -and $error.count -gt $ErrCount){ Write-Output $error 4>&1 | Out-File -Filepath $LogFile -NoNewline -Append }
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
				If($NetTCP -Contains $CurrServices.Name){ Return 'Manual' } Return $False
			}
			Return $C_Type
		}
		Return 'Already'
	}
	Return $False
}

##########
# Service Change Functions -End
##########
# Misc Functions -Start
##########

Function LoadWebCSV([Int]$ErrorChoice) {
	Switch($ErrorChoice) {
		0 { $Script:ErrorDi = 'Missing File BlackViper.csv -LoadCSV' ;$Pick = ' is Missing.' ;Break }
		1 { $Script:ErrorDi = 'Invalid/Corrupt BlackViper.csv' ;$Pick = ' is Invalid or Corrupt.' ;Break }
		Default { $Script:ErrorDi = 'BlackViper.csv Not Valid for current Update' ;$Pick = ' needs to be Updated.' ;Break }
	}
	$Pick = "$Pick".PadRight(25)
	While($LoadWebCSV -ne 'Out') {
		Error_Top_Display
		LeftLine ;DisplayOutMenu ' The File ' 2 0 0 ;DisplayOutMenu 'BlackViper.csv' 15 0 0 ;DisplayOutMenu $Pick 2 0 0 ;RightLine
		MenuBlankLine
		LeftLine ;DisplayOutMenu ' Do you want to download ' 2 0 0 ;DisplayOutMenu 'BlackViper.csv' 15 0 0 ;DisplayOutMenu '?         ' 2 0 0 ;RightLine
		MenuBlankLine
		MenuLine
		$Invalid = ShowInvalid $Invalid
		$LoadWebCSV = Read-Host "`nDownload? (Y)es/(N)o"
		Switch($LoadWebCSV.ToLower()) {
			{ $_ -eq 'y' -or $_ -eq 'yes' } { DownloadFile $Service_Url $ServiceFilePath ;$LoadWebCSV = 'Out' ;Break }
			{ $_ -eq 'n' -or $_ -eq 'no' } { DisplayOutMenu 'For manual download save the following File: ' 2 0 1 ;DisplayOutMenu 'https://github.com/madbomb122/BlackViperScript/raw/master/BlackViper.csv' 15 0 0 ;Exit ;Break }
			Default { $Invalid = 1 ;Break }
		}
	}
	If($ErrorChoice -In 1..2){ [System.Collections.ArrayList]$Script:csv = Import-Csv $ServiceFilePath }
	CheckBVcsv
	Return
}

Function LoadWebCSVGUI {
	ShowConsole 5
	Switch($ErrorChoice) {
		0 { $Script:ErrorDi = 'Missing File BlackViper.csv -LoadCSV' ;$ErrMessage = "The File 'BlackViper.csv' is Missing.`nDo you want to download the file 'BlackViper.csv'?" ;Break }
		1 { $Script:ErrorDi = 'Invalid/Corrupt BlackViper.csv' ;$ErrMessage = "The File 'BlackViper.csv' is Invalid or Corrupt.`nDo you want to download the file 'BlackViper.csv'?" ;Break }
		Default { $Script:ErrorDi = 'BlackViper.csv Not Valid for current Update' ;$ErrMessage = "The File 'BlackViper.csv' needs to be Updated.`nDo you want to download the file 'BlackViper.csv'?" ;Break }
	}
	If([windows.forms.messagebox]::show($ErrMessage,'Error','YesNo','Error') -eq 'Yes'){
		DownloadFile $Service_Url $ServiceFilePath
		If($ErrorChoice -In 1..2){ [System.Collections.ArrayList]$Script:csv = Import-Csv $ServiceFilePath }
		CheckBVcsv
	} Else {
		[Windows.Forms.MessageBox]::Show("To get The File 'BlackViper.csv' go to https://github.com/madbomb122/BlackViperScript to save it.`nWithout the file the script won't run",'Information','OK','Information') | Out-Null
		$Form.Close()
		Exit
	}
}

Function PreScriptCheck {
	If($RunScript -eq 0){ If($GuiLoad -eq 1){ $Form.Close() } ;Exit }
	If($LogStarted -eq 0){ CreateLog }
	$EBCount = 0

	If($EditionCheck -eq 'Home' -or $WinSku -In 100..101 -or $WinSku -eq 98) {
		$Script:WinEdition = 'Home'
	} ElseIf($EditionCheck -eq 'Pro' -or $WinSku -In 48..49) {
		$Script:WinEdition = 'Pro'
	} Else {
		$Script:ErrorDi = 'Edition'
		$EditionCheck = 'Fail'
		$EBCount++
	}

	If($Win10Ver -lt $MinVer -And $BuildCheck -ne 1) {
		If($EditionCheck -eq 'Fail'){ $Script:ErrorDi += ' & Build' } Else{ $Script:ErrorDi = 'Build' }
		$Script:ErrorDi += ' Check Failed'
		$BuildCheck = 'Fail'
		$EBCount++
	}

	If($EBCount -ne 0) {
	   $EBCount=0
		Error_Top_Display
		LeftLineLog ;DisplayOutMenu " Script won't run due to the following problem(s)" 2 0 0 1 ;RightLineLog
		MenuBlankLineLog
		MenuLineLog
		If($EditionCheck -eq 'Fail') {
			$EBCount++
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu " $EBCount. Not a valid Windows Edition for this Script. " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' Windows 10 Home and Pro Only'.PadRight(49) 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu ' You are using ' 2 0 0 1;DisplayOutMenu $FullWinEdition.PadRight(34) 15 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' SKU # ' 2 0 0 1;DisplayOutMenu $WinSku.PadRight(41) 15 0 0 1 ;RightLineLog
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu ' If you are using Home or Pro...'.PadRight(49) 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' Please contact me with'.PadRight(49) 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' 1. What Edition you are using'.PadRight(49) 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' 2. The SKU # listed above'.PadRight(49) 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu ' To skip use one of the following methods        ' 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' 1. Change ' 2 0 0 1 ;DisplayOutMenu 'EditionCheck' 15 0 0 1 ;DisplayOutMenu ' in script file           ' 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' 2. Change ' 2 0 0 1 ;DisplayOutMenu 'Skip_EditionCheck' 15 0 0 1 ;DisplayOutMenu ' to ' 2 0 0 1 ;DisplayOutMenu '=yes' 15 0 0 1 ;DisplayOutMenu ' in bat file ' 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' 3. Run Script or Bat file with ' 2 0 0 1 ;DisplayOutMenu '-secp' 15 0 0 1 ;DisplayOutMenu ' argument   ' 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' 4. Run Script or Bat file with ' 2 0 0 1 ;DisplayOutMenu '-sech' 15 0 0 1 ;DisplayOutMenu ' argument   ' 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			MenuLineLog
		}
		If($BuildCheck -eq 'Fail') {
			$EBCount++
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu " $EBCount. Not a valid Build for this Script.           " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " Lowest Build Recommended is Creator's Update    " 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu ' You are using Build ' 2 0 0 1 ;DisplayOutMenu $BuildVer.PadRight(24) 15 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' You are using Version ' 2 0 0 1 ;DisplayOutMenu $Win10Ver.PadRight(26) 15 0 0 1 ;RightLineLog
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu ' To skip use one of the following methods        ' 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' 1. Change ' 2 0 0 1 ;DisplayOutMenu 'BuildCheck' 15 0 0 1 ;DisplayOutMenu ' to ' 2 0 0 1 ;DisplayOutMenu '=1' 15 0 0 1 ;DisplayOutMenu ' in script file       ' 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' 2. Change ' 2 0 0 1 ;DisplayOutMenu 'Skip_BuildCheck' 15 0 0 1 ;DisplayOutMenu ' to ' 2 0 0 1 ;DisplayOutMenu '=yes' 15 0 0 1 ;DisplayOutMenu ' in bat file   ' 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu ' 3. Run Script or Bat file with ' 2 0 0 1 ;DisplayOutMenu '-sbc' 15 0 0 1 ;DisplayOutMenu ' argument    ' 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			MenuLineLog
		}
		AutomatedExitCheck 1
	}
	If($BackupServiceConfig -eq 1){
		Switch($BackupServiceType) {
			1 { Save_ServiceBackup ;Break }
			0 { RegistryServiceFileBackup ;Break }
			2 { Save_ServiceBackup ;RegistryServiceFileBackup ;Break }
		}
	}
	If($LoadServiceConfig -eq 1) {
		$ServiceFilePath = $ServiceConfigFile
		If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
			$Script:ErrorDi = 'Missing File $ServiceConfigFile'
			Error_Top_Display
			LeftLineLog ;DisplayOutMenu 'The File ' 2 0 0 1 ;DisplayOutMenu $ServiceConfigFile.PadRight(28) 15 0 0 1 ;DisplayOutMenu ' is missing.' 2 0 0 1 ;RightLineLog
			Error_Bottom
		}
		$ServiceVerCheck = 0
	} ElseIf($LoadServiceConfig -eq 2) {
		# Yes this is supposed to be EMPTY
	} Else {
		$ServiceFilePath = $filebase + 'BlackViper.csv'
		If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
			If($ServiceVerCheck -eq 0) {
				If($ScriptLog -eq 1){ Write-Output "Missing File 'BlackViper.csv'" | Out-File -Filepath $LogFile }
				If($GuiLoad -eq 1){ LoadWebCSVGUI 0 } Else{ LoadWebCSV 0 }
				LoadWebCSV 0
			} Else {
				If($ScriptLog -eq 1){ Write-Output "Downloading Missing File 'BlackViper.csv'" | Out-File -Filepath $LogFile }
				DownloadFile $Service_Url $ServiceFilePath
			}
			$ServiceVerCheck = 0
		}
	}
	If($LoadServiceConfig -ne 2){ [System.Collections.ArrayList]$Script:csv = Import-Csv $ServiceFilePath }
	If($ScriptVerCheck -eq 1 -or $ServiceVerCheck -eq 1){ UpdateCheckAuto }
	If($LoadServiceConfig -ne 2){ CheckBVcsv ;$csv.RemoveAt(0) }
}

Function CheckBVcsv {
	$GenBy = $csv[0].'Def-Pro-Full'
	If($GenBy -ne 'GernetatedByMadBomb122' -and $GenBy -ne 'GeneratedByMadBomb122') {
		If($Automated -ne 1) {
			If($GuiLoad -eq 1){ LoadWebCSVGUI 1 } Else{ LoadWebCSV 1 }
		} Else {
			Error_Top_Display
			LeftLineLog ;DisplayOutMenu 'The File ' 2 0 0 1 ;DisplayOutMenu 'BlackViper.csv' 15 0 0 1 ;DisplayOutMenu ' is Invalid or Corrupt.   ' 2 0 0 1 ;RightLineLog
			Error_Bottom
		}
	} ElseIf(!(Test-Path $ServiceFilePath -PathType Leaf)) {
		If($GuiLoad -eq 1){
			[Windows.Forms.MessageBox]::Show("The File 'BlackViper.csv' is missing and couldn't be downloaded.`nFor Manual download go to https://github.com/madbomb122/BlackViperScript",'Information', 'OK','Information') | Out-Null
		} Else{
			$Script:ErrorDi = 'Missing File BlackViper.csv'
			Error_Top_Display
			LeftLineLog ;DisplayOutMenu 'The File ' 2 0 0 1 ;DisplayOutMenu 'BlackViper.csv' 15 0 0 1 ;DisplayOutMenu " is missing and couldn't  " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu "couldn't download for some reason.".PadRight(49) 2 0 0 1 ;RightLineLog
			Error_Bottom
		}
	}
	If($GuiLoad -eq 1){ $WPF_LoadServicesButton.IsEnabled = SetServiceVersion } Else{ SetServiceVersion | Out-Null }
}

Function GetArgs {
	For($i=0 ;$i -lt $PassedArg.Length ;$i++) {
		If($PassedArg[$i].StartsWith('-')) {
			Switch($PassedArg[$i]) {
				'-default' { $Script:Black_Viper = 1 ;$Script:BV_ArgUsed = 2 ;Break }
				'-safe' { $Script:Black_Viper = 2 ;$Script:BV_ArgUsed = 2;Break }
				'-tweaked' { If($IsLaptop -ne '-Lap'){ $Script:Black_Viper = 3 ;$Script:BV_ArgUsed = 2 } Else{ $Script:BV_ArgUsed = 1 } ;Break }
				'-all' { $Script:All_or_Min = '-full' ;Break }
				'-min' { $Script:All_or_Min = '-min' ;Break }
				'-log' { $Script:ScriptLog = 1 ;If(!($PassedArg[$i+1].StartsWith('-'))){ $Script:LogName = $PassedArg[$i+1] ;$i++ } ;Break }
				'-logc' { $Script:ScriptLog = 2 ;If(!($PassedArg[$i+1].StartsWith('-'))){ $Script:LogName = $PassedArg[$i+1] ;$i++ } ;Break } #To append to logfile (used for update)
				'-lcsc' { $Script:BV_ArgUsed = 3 ;$Script:LoadServiceConfig = 1 ;If(!($PassedArg[$i+1].StartsWith('-'))){ $Script:ServiceConfigFile = $PassedArg[$i+1] ;$i++ } ;Break }
				'-bscc' { $Script:BackupServiceConfig = 1 ;$Script:BackupServiceType = 1 ;Break }
				'-bscr' { $Script:BackupServiceConfig = 1 ;$Script:BackupServiceType = 0 ;Break }
				'-bscb' { $Script:BackupServiceConfig = 1 ;$Script:BackupServiceType = 2 ;Break }
				'-baf' { $Script:LogBeforeAfter = 1 ;Break }
				'-snis' { $Script:ShowNonInstalled = 1 ;Break }
				'-sss' { $Script:ShowSkipped = 1 ;Break }
				'-sic' { $Script:InternetCheck = 1 ;Break }
				'-usc' { $Script:ScriptVerCheck = 1 ;Break }
				'-use' { $Script:ServiceVerCheck = 1 ;Break }
				'-atos' { $Script:AcceptToS = 'Accepted-Switch' ;Break }
				'-atosu' { $Script:AcceptToS = 'Accepted' ;Break }
				'-auto' { $Script:Automated = 1 ;$Script:AcceptToS = 'Accepted-Automated' ;Break }
				'-dry' { $Script:DryRun = 1 ;$Script:ShowNonInstalled = 1 ;Break }
				'-diag' { $Script:Diagnostic = 1 ;$Script:Automated = 0 ;Break }
				'-diagf' { $Script:Diagnostic = 2 ;$Script:Automated = 0 ;$Script:ErrorDi = 'Forced Diag Output' ;Break }
				'-devl' { $Script:DevLog = 1 ;Break }
				'-sbc' { $Script:BuildCheck = 1 ;Break }
				'-sech' { $Script:EditionCheck = 'Home' ;Break }
				'-sxb' { $Script:XboxService = 1 ;Break }
				{$_ -eq '-secp' -or $_ -eq '-sec'} { $Script:EditionCheck = 'Pro' ;Break }
				{$_ -eq '-help' -or $_ -eq '-h'} { ShowHelp ;Break }
			}
		}
	}
}

Function ShowHelp {
	Clear-Host
	DisplayOutMenu '                  List of Switches'.PadRight(53) 13 0 1 0
	DisplayOutMenu ''.PadRight(53,'-') 14 0 1 0
	DisplayOutMenu '-- Basic Switches --' 2 0 1 0
	DisplayOutMenu ' Switch ' 15 0 0 0 ;DisplayOut 'Description of Switch'.PadLeft(31) 14 0 1 0
	DisplayOutMenu '  -atos ' 15 0 0 0 ;DisplayOutMenu '           Accepts ToS' 14 0 1 0
	DisplayOutMenu '  -auto ' 15 0 0 0 ;DisplayOutMenu '           Implies ' 14 0 0 0 ;DisplayOutMenu '-atos' 15 0 0 0 ;DisplayOutMenu '...Runs the script to be Automated.. Closes on - User Input, Errors, or End of Script' 14 0 1 0
	DisplayOutMenu "`n--Service Configuration Switches--" 2 0 1 0
	DisplayOutMenu ' Switch ' 15 0 0 0 ;DisplayOut 'Description of Switch'.PadLeft(31) 14 0 1 0
	DisplayOutMenu '  -default ' 15 0 0 0 ;DisplayOutMenu '        Runs the script with Services to Default Configuration' 14 0 1 0
	DisplayOutMenu '  -safe ' 15 0 0 0 ;DisplayOutMenu "           Runs the script with Services to Black Viper's Safe Configuration" 14 0 1 0
	DisplayOutMenu '  -tweaked ' 15 0 0 0 ;DisplayOutMenu "        Runs the script with Services to Black Viper's Tweaked Configuration" 14 0 1 0
	DisplayOutMenu '  -lcsc ' 15 0 0 0 ;DisplayOutMenu 'File.csv ' 11 0 0 ;DisplayOutMenu '  Loads Custom Service Configuration, '  14 0 0 0 ;DisplayOutMenu 'File.csv' 11 0 0 0 ;DisplayOutMenu ' = Name of your backup/custom file' 14 0 1 0
	DisplayOutMenu "`n--Service Choice Switches--" 2 0 1 0
	DisplayOutMenu ' Switch' 15 0 0 0 ;DisplayOut 'Description of Switch'.PadLeft(31) 14 0 1 0
	DisplayOutMenu '  -all ' 15 0 0 0 ;DisplayOutMenu '            Every windows services will change' 14 0 1 0
	DisplayOutMenu '  -min ' 15 0 0 0 ;DisplayOutMenu '            Just the services different from the default to safe/tweaked list' 14 0 1 0
	DisplayOutMenu '  -sxb ' 15 0 0 0 ;DisplayOutMenu '            Skips changes to all XBox Services' 14 0 1 0
	DisplayOutMenu "`n--Update Switches--" 2 0 1 0
	DisplayOutMenu ' Switch' 15 0 0 0 ;DisplayOut ' Description of Switch'.PadLeft(31) 14 0 1 0
	DisplayOutMenu '  -usc ' 15 0 0 0 ;DisplayOutMenu '            Checks for Update to Script file before running' 14 0 1 0
	DisplayOutMenu '  -use ' 15 0 0 0 ;DisplayOutMenu '            Checks for Update to Service file before running' 14 0 1 0
	DisplayOutMenu '  -sic ' 15 0 0 0 ;DisplayOutMenu "            Skips Internet Check, if you can't ping GitHub.com for some reason" 14 0 1 0
	DisplayOutMenu "`n--Log Switches--" 2 0 1 0
	DisplayOutMenu ' Switch' 15 0 0 0 ;DisplayOut ' Description of Switch'.PadLeft(31) 14 0 1 0
	DisplayOutMenu '  -log ' 15 0 0 0 ;DisplayOutMenu '            Makes a log file '  14 0 0 0 ;DisplayOutMenu 'Script.log' 11 0 1 0
	DisplayOutMenu '  -baf ' 15 0 0 0 ;DisplayOutMenu '            Log File of Services Configuration Before and After the script' 14 0 1 0
	DisplayOutMenu "`n--Backup Service Configuration--" 2 0 1 0
	DisplayOutMenu ' Switch ' 15 0 0 0 ;DisplayOut 'Description of Switch'.PadLeft(31) 14 0 1 0
	DisplayOutMenu '  -bscc ' 15 0 0 0 ;DisplayOutMenu '           Backup Current Service Configuration, Csv File' 14 0 1 0
	DisplayOutMenu '  -bscr ' 15 0 0 0 ;DisplayOutMenu '           Backup Current Service Configuration, Reg File' 14 0 1 0
	DisplayOutMenu '  -bscb ' 15 0 0 0 ;DisplayOutMenu '           Backup Current Service Configuration, Csv and Reg File' 14 0 1 0
	DisplayOutMenu "`n--Misc Switches--" 2 0 1 0
	DisplayOutMenu ' Switch ' 15 0 0 0 ;DisplayOut 'Description of Switch'.PadLeft(31) 14 0 1 0
	DisplayOutMenu '  -dry  ' 15 0 0 0 ;DisplayOutMenu '           Runs the script and shows what services will be changed' 14 0 1 0
	DisplayOutMenu '  -diag ' 15 0 0 0 ;DisplayOutMenu '           Shows diagnostic information, Stops '  14 0 0 0 ;DisplayOutMenu '-auto' 15 0 1 0
	DisplayOutMenu '  -snis ' 15 0 0 0 ;DisplayOutMenu '           Show not installed Services' 14 0 1 0
	DisplayOutMenu '  -sss  ' 15 0 0 0 ;DisplayOutMenu '           Show Skipped Services' 14 0 1 0
	DisplayOutMenu "`n--AT YOUR OWN RISK Switches--"  13 0 1 0
	DisplayOutMenu ' Switch ' 15 0 0 0 ;DisplayOut 'Description of Switch'.PadLeft(31) 14 0 1 0
	DisplayOutMenu '  -secp ' 15 0 0 0 ;DisplayOutMenu '           Skips Edition Check by Setting Edition as Pro' 14 0 1 0
	DisplayOutMenu '  -sech ' 15 0 0 0 ;DisplayOutMenu '           Skips Edition Check by Setting Edition as Home' 14 0 1 0
	DisplayOutMenu '  -sbc  ' 15 0 0 0 ;DisplayOutMenu '           Skips Build Check' 14 0 1 0
	AutomatedExitCheck 1
	Exit
}

Function ArgsAndVarSet {
	If(Test-Path $SettingPath -PathType Leaf){ Import-Clixml $SettingPath  | ForEach-Object { Set-Variable $_.Var $_.Val -Scope Script } }
	$Script:PCType = (Get-CimInstance -Class Win32_ComputerSystem).PCSystemType
	If($PCType -ne 2){ $Script:IsLaptop = '-Desk' } Else{ $Script:IsLaptop = '-Lap' }
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

	If($Diagnostic -eq 2) {
		Clear-Host
		DiagnosticCheck 1
		If($GuiLoad -eq 1){ $Form.Close() }
		Exit
	} ElseIf($BV_ArgUsed -eq 1) {
		CreateLog
		Error_Top_Display
		$Script:ErrorDi = 'Tweaked + Laptop (Not supported)'
		If($Automated -eq 1){ LeftLineLog ;DisplayOutMenu 'Script is set to Automated and...'.PadRight(49) 2 0 0 1 ;RightLineLog }
		LeftLineLog ;DisplayOutMenu "Laptops can't use Tweaked option.".PadRight(49) 2 0 0 1 ;RightLineLog
		Error_Bottom
	} ElseIf($BV_ArgUsed -In 2..3) {
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
		LeftLineLog ;DisplayOutMenu 'Script is set to Automated and no Service        ' 2 0 0 1 ;RightLineLog
		LeftLineLog ;DisplayOutMenu 'Configuration option was selected.               ' 2 0 0 1 ;RightLineLog
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
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!                                            !!
## !!            SAFE TO EDIT VALUES             !!
## !!                                            !!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Edit values (Option) to your Choice
# Function = Option
# Choices

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

$Script:LogName = "Script-Log.txt"
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
# Starts the script (Do not change)
ArgsAndVarSet
