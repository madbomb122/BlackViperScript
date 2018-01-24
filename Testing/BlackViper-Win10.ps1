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
$Script_Version = "4.1"
$Minor_Version = "0"
$Script_Date = "Jan-16-2018"
$Release_Type = "Testing"
#$Release_Type = "Stable"
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

The MIT License (MIT)

Copyright (c) 2017 Madbomb122 - Black Viper Service Script

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

--------------------------------------------------------------------------------

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

--Misc Switches--
  -sxb           (Skips changes to all XBox Services)
  -bcsc          (Backup Current Service Configuration)
  -dry           (Runs the script and shows what services will be changed)
  -diag          (Shows diagnostic information, Stops -auto)
  -snis          (Show not installed Services)
------------------------------------------------------------------------------#>
##########
# Pre-Script -Start
##########

$Script:WindowVersion = [Environment]::OSVersion.Version.Major
If($WindowVersion -ne 10) {
	Clear-Host
	Write-Host "Sorry, this Script supports Windows 10 ONLY." -ForegroundColor "cyan" -BackgroundColor "black"
	If($Automated -ne 1){ Read-Host -Prompt "`nPress Any key to Close..." }
	Exit
}

If($Release_Type -eq "Stable"){ $ErrorActionPreference = 'silentlycontinue' }

$Script:PassedArg = $args
$Script:filebase = $PSScriptRoot + "\"

If(!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $PassedArg" -Verb RunAs ;Exit
}

$URL_Base = "https://raw.githubusercontent.com/madbomb122/BlackViperScript/master/"
$Version_Url = $URL_Base + "Version/Version.csv"
$Service_Url = $URL_Base + "BlackViper.csv"

If([System.Environment]::Is64BitProcess){ $OSType = 64 }
$Script:ServiceEnd = (Get-Service "*_*" | Select-Object Name | Select-Object -First 1).Name.Split('_')[1]

$colors = @(
"black",      #0
"blue",       #1
"cyan",       #2
"darkblue",   #3
"darkcyan",   #4
"darkgray",   #5
"darkgreen",  #6
"darkmagenta",#7
"darkred",    #8
"darkyellow", #9
"gray",       #10
"green",      #11
"magenta",    #12
"red",        #13
"white",      #14
"yellow")     #15

$ServicesTypeList = @(
'',         #0 -Skip Not Installed
'Disabled', #1 -Disable
'Manual',   #2 -Manual
'Automatic',#3 -Automatic
'Automatic')#4 -Automatic (Delayed Start)

$ServicesRegTypeList = @(
'',  #0 -None
'4', #1 -Disable
'3', #2 -Manual
'2', #3 -Automatic
'2') #4 -Automatic (Delayed Start)

$XboxServiceArr = @("xbgm","XblAuthManager", "XblGameSave", "XboxNetApiSvc")
$Script:Black_Viper = 0
$Script:All_or_Min = "-min"
$Script:RunScript = 2
$Script:ErrorDi = ""
$Script:LogStarted = 0
$Script:XboxService = 0

##########
# Pre-Script -End
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

Function OpenWebsite([String]$Url) { [System.Diagnostics.Process]::Start($Url) }
Function DownloadFile([String]$Url,[String]$FilePath) { (New-Object System.Net.WebClient).DownloadFile($Url, $FilePath) }
Function ShowInvalid([Int]$InvalidA) { If($InvalidA -eq 1) { Write-Host "`nInvalid Input" -ForegroundColor Red -BackgroundColor Black -NoNewline } Return 0 }
Function LaptopCheck { $Script:PCType = (Get-WmiObject -Class Win32_ComputerSystem).PCSystemType ;If($PCType -ne 2) { Return "-Desk" } Return "-Lap" }

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

Function  AutomatedExitCheck([Int]$ExitBit) {
	If($Automated -ne 1){ Read-Host -Prompt "`nPress Any key to Close..." }
	If($ExitBit -eq 1){ Exit }
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
	MenuBlankLineLog
	MenuLineLog
	If($Diagnostic -eq 1) {
		DiagnosticCheck 0
		Read-Host -Prompt "`nPress Any key to Close..."
		Exit
	} Else {
		AutomatedExitCheck 1
	}
}

Function DiagnosticCheck([Int]$Bypass) {
	If($Release_Type -ne "Stable" -or $Bypass -eq 1 -or $Diagnostic -eq 1) {
		DisplayOutMenu " Diagnostic Output" 15 0 1 1
		DisplayOutMenu " Some items may be blank" 15 0 1 1
		DisplayOutMenu " --------Start--------" 15 0 1 1
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
# Multi Use Functions -End
##########
# TOS -Start
##########

Function TOSDisplay {
	Clear-Host
	$BorderColor = 14
	If($Release_Type -ne "Stable") {
		$BorderColor = 15
		DisplayOut "|---------------------------------------------------|" $BorderColor 0 1
		DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "                  Caution!!!                     " 13 0 0 ;DisplayOut " |" $BorderColor 0 1
		DisplayOut "|                                                   |" $BorderColor 0 1
		DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu " This script is still being tested.              " 14 0 0 ;DisplayOut " |" $BorderColor 0 1
		DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "              USE AT YOUR OWN RISK.              " 14 0 0 ;DisplayOut " |" $BorderColor 0 1
		DisplayOut "|                                                   |" $BorderColor 0 1
	}
	If($OSType -ne 64) {
		$BorderColor = 15
		DisplayOut "|---------------------------------------------------|" $BorderColor 0 1
		DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "                    WARNING!!                    " 13 0 0 ;DisplayOut " |" $BorderColor 0 1
		DisplayOut "|                                                   |" $BorderColor 0 1
		DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "      These settings are ment for x64 Bit.       " 14 0 0 ;DisplayOut " |" $BorderColor 0 1
		DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "              USE AT YOUR OWN RISK.              " 14 0 0 ;DisplayOut " |" $BorderColor 0 1
		DisplayOut "|                                                   |" $BorderColor 0 1
	}
	DisplayOut "|---------------------------------------------------|" $BorderColor 0 1
	DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "                  Terms of Use                   " 11 0 0 ;DisplayOut " |" $BorderColor 0 1
	DisplayOut "|---------------------------------------------------|" $BorderColor 0 1
	DisplayOut "|                                                   |" $BorderColor 0 1
	DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "This program comes with ABSOLUTELY NO WARRANTY.  " 2 0 0 ;DisplayOut " |" $BorderColor 0 1
	DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "This is free software, and you are welcome to    " 2 0 0 ;DisplayOut " |" $BorderColor 0 1
	DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "redistribute it under certain conditions.        " 2 0 0 ;DisplayOut " |" $BorderColor 0 1
	DisplayOut "|                                                   |" $BorderColor 0 1
	DisplayOutMenu "| " $BorderColor 0 0 ;DisplayOutMenu "Read License file for full Terms.                " 2 0 0 ;DisplayOut " |" $BorderColor 0 1
	DisplayOut "|                                                   |" $BorderColor 0 1
	DisplayOut "|---------------------------------------------------|" $BorderColor 0 1
}

Function TOS {
	While($TOS -ne "Out") {
		TOSDisplay
		$Invalid = ShowInvalid $Invalid
		$TOS = Read-Host "`nDo you Accept? (Y)es/(N)o"
		Switch($TOS.ToLower()) {
			{$_ -eq "n" -or $_ -eq "no"} { Exit ;Break }
			{$_ -eq "y" -or $_ -eq "yes"} { $TOS = "Out" ;TOSyes ;Break }
			Default { $Invalid = 1 ;Break }
		}
	} Return
}

Function TOSyes {
	$Script:AcceptToS = "Accepted-Script"
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
	If($Property -eq "Close"){ $syncHash.Window.Dispatcher.invoke([action]{$syncHash.Window.Close()},"Normal") ;Return }
	$form.Dispatcher.Invoke([Action]{ If($PSBoundParameters['AppendContent']){ $Control.AppendText($Value) } Else{ $Control.$Property = $Value } }, "Normal")
}

Function OpenSaveDiaglog([Int]$SorO) {
	If($SorO -eq 0){ $SOFileDialog = New-Object System.Windows.Forms.OpenFileDialog } Else{ $SOFileDialog = New-Object System.Windows.Forms.SaveFileDialog }
	$SOFileDialog.InitialDirectory = $filebase
	If($SorO -ne 2){ $SOFileDialog.Filter = "CSV (*.csv)| *.csv" } Else{ $SOFileDialog.Filter = "Registration File (*.reg)| *.reg" }
	$SOFileDialog.ShowDialog()
	$SOFPath = $SOFileDialog.filename
	If($SOFPath){
		If($SorO -eq 0){
			$Script:ServiceConfigFile = $SOFPath
			$WPF_LoadFileTxtBox.Text = $ServiceConfigFile
			RunDisableCheck
		} ElseIf($SorO -eq 1){
			Save_Service $SOFPath
		} ElseIf($SorO -eq 2){
			RegistryServiceFile $SOFPath
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

Function GuiStart {
	Clear-Host
	DisplayOutMenu "Preparing GUI, Please wait..." 15 0 1 0
	$TPath = $filebase + "BlackViper.csv"
	If(Test-Path $TPath -PathType Leaf) {
		$TMP = Import-Csv $TPath
		$ServiceVersion = ($TMP[0]."Def-Home-Full")
		$ServiceDate = ($TMP[0]."Def-Home-Min")
	} Else {
		$ServiceVersion = "Missing File"
		$ServiceDate = "BlackViper.csv"
	}

[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Black Viper Service Configuration Script By: MadBomb122" Height="330" Width="490" BorderBrush="Black" Background="White">
<Window.Effect> <DropShadowEffect/></Window.Effect><Grid>
 <Label Content="Service Version:" HorizontalAlignment="Left" Margin="256,0,0,-1" VerticalAlignment="Bottom" Height="25"/>
 <Label Content="Script Version:" HorizontalAlignment="Left" Margin="1,0,0,-1" VerticalAlignment="Bottom" Height="25"/>
 <Button Name="CopyrightButton" Content="Copyright" HorizontalAlignment="Left" Margin="114,0,0,21" VerticalAlignment="Bottom" Width="114" FontStyle="Italic" Background="#FF8ABEF0"/>
 <Button Name="BlackViperWSButton" Content="BlackViper's Website" HorizontalAlignment="Left" Margin="228,0,0,21" VerticalAlignment="Bottom" Width="117" FontStyle="Italic" Background="#FFA7D24D"/>
 <Button Name="Madbomb122WSButton" Content="Madbomb122's Website" HorizontalAlignment="Left" Margin="345,0,0,21" VerticalAlignment="Bottom" Width="129" FontStyle="Italic" Background="#FFA7D24D"/>
 <Button Name="DonateButton" Content="Donate to me" HorizontalAlignment="Left" Margin="0,0,0,21" VerticalAlignment="Bottom" Width="114" FontStyle="Italic" Background="#FFFFAD2F"/>
 <Button Name="RunScriptButton" Content="Run Script" HorizontalAlignment="Left" Margin="0,0,0,42" VerticalAlignment="Bottom" Width="474" Height="20" FontWeight="Bold"/>
 <TextBox Name="Script_Ver_Txt" HorizontalAlignment="Left" Height="20" Margin="82,0,0,0" TextWrapping="Wrap" Text="2.8.0 (6-21-2017)" VerticalAlignment="Bottom" Width="125" IsEnabled="False"/>
 <TextBox Name="Service_Ver_Txt" HorizontalAlignment="Left" Height="20" Margin="345,0,0,0" TextWrapping="Wrap" Text="2.0 (5-21-2017)" VerticalAlignment="Bottom" Width="129" IsEnabled="False"/>
 <TextBox Name="Release_Type_Txt" HorizontalAlignment="Left" Height="20" Margin="207,0,0,0" TextWrapping="Wrap" Text="Testing" VerticalAlignment="Bottom" Width="48" IsEnabled="False"/>
 <TabControl Name="TabControl" Margin="0,0,0,65">
  <TabItem Name="Services_Tab" Header="Services Options" Margin="-2,0,2,0"><Grid Background="#FFE5E5E5">
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
   <Label Name="CustomNote1" Content="*Note: Configure Bellow" HorizontalAlignment="Left" Margin="262,63,0,0" VerticalAlignment="Top" Width="148" Height="27" FontWeight="Bold"/>
   <Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,97,-6,0" Stroke="Black" VerticalAlignment="Top"/>
   <Button Name="btnOpenFile" Content="Browse File" HorizontalAlignment="Left" Margin="5,120,0,0" VerticalAlignment="Top" Width="66" Height="22"/>
   <TextBox Name="LoadFileTxtBox" HorizontalAlignment="Left" Height="50" Margin="5,150,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="461" IsReadOnly="True" Background="#FFECECEC"/>
   <Label Name="CustomNote3" Content="Config File: Browse for file" HorizontalAlignment="Left" Margin="76,118,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
   <Label Name="CustomNote2" Content="Custom Configuration" HorizontalAlignment="Left" Margin="164,95,0,0" VerticalAlignment="Top" Width="135" Height="26" FontWeight="Bold"/></Grid>
  </TabItem>
  <TabItem Name="Options_tab" Header="Script Options" Margin="-2,0,2,0"><Grid Background="#FFE5E5E5">
   <Label Content="Display Options" HorizontalAlignment="Left" Margin="4,5,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
   <Label Content="Log Options" HorizontalAlignment="Left" Margin="4,138,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
   <Label Content="Misc Options" HorizontalAlignment="Left" Margin="4,67,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
   <CheckBox Name="Dryrun_CB" Content="Dryrun -Shows what will be changed" HorizontalAlignment="Left" Margin="9,90,0,0" VerticalAlignment="Top" Height="15" Width="213"/>
   <CheckBox Name="LogBeforeAfter_CB" Content="Services Before and After" HorizontalAlignment="Left" Margin="9,160,0,0" VerticalAlignment="Top" Height="16" Width="158"/>
   <CheckBox Name="ShowAlreadySet_CB" Content="Show Already Set Services" HorizontalAlignment="Left" Margin="9,28,0,0" VerticalAlignment="Top" Height="15" Width="158" IsChecked="True"/>
   <CheckBox Name="ShowNonInstalled_CB" Content="Show Not Installed Services" HorizontalAlignment="Left" Margin="9,43,0,0" VerticalAlignment="Top" Height="15" Width="166"/>
   <CheckBox Name="ScriptLog_CB" Content="Script Log:" HorizontalAlignment="Left" Margin="9,176,0,0" VerticalAlignment="Top" Height="14" Width="76"/>
   <CheckBox Name="BackupServiceConfig_CB" Content="Backup Current Service Configuration" HorizontalAlignment="Left" Margin="9,105,0,-11" VerticalAlignment="Top" Height="15" Width="218"/>
   <CheckBox Name="XboxService_CB" Content="Skip All Xbox Services" HorizontalAlignment="Left" Margin="9,120,0,0" VerticalAlignment="Top" Height="15" Width="218"/>   
   <TextBox Name="LogNameInput" HorizontalAlignment="Left" Height="20" Margin="87,174,0,0" TextWrapping="Wrap" Text="Script.log" VerticalAlignment="Top" Width="140" IsEnabled="False"/>
   <CheckBox Name="ScriptVerCheck_CB" Content="Script Update*" HorizontalAlignment="Left" Margin="244,105,0,0" VerticalAlignment="Top" Height="15" Width="99"/>
   <CheckBox Name="BatUpdateScriptFileName_CB" Content="Update Bat file with new Script file**" HorizontalAlignment="Left" Margin="244,120,0,0" VerticalAlignment="Top" Height="15" Width="214"/>
   <CheckBox Name="ServiceUpdateCB" Content="Service Update" HorizontalAlignment="Left" Margin="244,90,0,0" VerticalAlignment="Top" Height="15" Width="99"/>
   <CheckBox Name="InternetCheck_CB" Content="Skip Internet Check" HorizontalAlignment="Left" Margin="244,135,0,0" VerticalAlignment="Top" Height="15" Width="124"/>
   <Label Content="*Will run and use current settings&#xA;**If update.bat isnt avilable" HorizontalAlignment="Left" Margin="238,144,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
   <Label Content="Update Items" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="239,67,0,0" FontWeight="Bold"/>
   <CheckBox Name="BuildCheck_CB" Content="Skip Build Check" HorizontalAlignment="Left" Margin="244,28,0,0" VerticalAlignment="Top" Height="15" Width="110"/>
   <CheckBox Name="EditionCheck_CB" Content="Skip Edition Check Set as :" HorizontalAlignment="Left" Margin="244,43,0,0" VerticalAlignment="Top" Height="15" Width="160"/>
   <ComboBox Name="EditionConfig" HorizontalAlignment="Left" Margin="404,40,0,0" VerticalAlignment="Top" Width="60" Height="23">
    <ComboBoxItem Content="Home" HorizontalAlignment="Left" Width="58"/>
    <ComboBoxItem Content="Pro" HorizontalAlignment="Left" Width="58" IsSelected="True"/>
   </ComboBox>
   <Label Content="SKIP CHECK AT YOUR OWN RISK!" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="238,5,0,0" FontWeight="Bold"/>
   <Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="236,-3,0,-1" Stroke="Black" Width="1"/></Grid>
  </TabItem>
  <TabItem Name="ServicesCB_Tab" Header="Services List" Margin="-2,0,2,0"><Grid Background="#FFE5E5E5">
    <DataGrid Name="dataGrid" AutoGenerateColumns="False" AlternationCount="1" SelectionMode="Single" IsReadOnly="True" HeadersVisibility="Column" Margin="-2,38,0,-2" AlternatingRowBackground="#FFD8D8D8" CanUserResizeRows="False" ><DataGrid.Columns>
     <DataGridCheckBoxColumn Binding="{Binding checkboxChecked, UpdateSourceTrigger=PropertyChanged}"><DataGridCheckBoxColumn.ElementStyle>
     <Style TargetType="CheckBox"/></DataGridCheckBoxColumn.ElementStyle></DataGridCheckBoxColumn>
     <DataGridTextColumn Header="Common Name" Width="121" Binding="{Binding CName}"/>
     <DataGridTextColumn Header="Service Name" Width="120" Binding="{Binding ServiceName}"/>
     <DataGridTextColumn Header="Current Setting" Width="95"  Binding="{Binding CurrType}"/>
     <DataGridTextColumn Header="Black Viper" Width="95"  Binding="{Binding BVType}"/>
    </DataGrid.Columns></DataGrid>
   <Rectangle Fill="#FFFFFFFF" Height="1" Margin="-2,37,2,0" Stroke="Black" VerticalAlignment="Top"/>
   <Button Name="SaveCustomSrvButton" Content="Save Current" HorizontalAlignment="Left" Margin="103,1,0,0" VerticalAlignment="Top" Width="80" Visibility="Hidden"/>
   <Button Name="SaveRegButton" Content="Save Registry" HorizontalAlignment="Left" Margin="198,1,0,0" VerticalAlignment="Top" Width="80" Visibility="Hidden"/>
   <Button Name="LoadServicesButton" Content="Load Services" HorizontalAlignment="Left" Margin="3,1,0,0" VerticalAlignment="Top" Width="76"/>
   <Label Name="ServiceNote" Content="Uncheck what you &quot;Don't want to be changed&quot;" HorizontalAlignment="Left" Margin="196,15,0,0" VerticalAlignment="Top" Visibility="Hidden"/>
   <Label Name="ServiceLegendLabel" Content="Service -&gt; Current -&gt; Changed To" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="-2,15,0,0" Visibility="Hidden"/>
   <Label Name="ServiceClickLabel" Content="&lt;-- Click to load Service List" HorizontalAlignment="Left" Margin="75,-3,0,0" VerticalAlignment="Top"/>
   <CheckBox Name="CustomBVCB" Content="Use Checked Services" HorizontalAlignment="Left" Margin="288,3,0,0" VerticalAlignment="Top" Width="158" RenderTransformOrigin="0.696,0.4" Visibility="Hidden"/></Grid>
  </TabItem>
  <TabItem Name="Dev_Option_Tab" Header="Dev Option/Contact/About" Margin="-2,0,2,0"><Grid Background="#FFE5E5E5">
   <CheckBox Name="Diagnostic_CB" Content="Diagnostic Output (On Error)" HorizontalAlignment="Left" Margin="9,18,0,0" VerticalAlignment="Top" Height="15" Width="174"/>
   <CheckBox Name="DevLog_CB" Content="Dev Log" HorizontalAlignment="Left" Margin="9,33,0,0" VerticalAlignment="Top" Height="15" Width="174"/>
   <Button Name="EMail" Content="e-mail Madbomb122" HorizontalAlignment="Left" Margin="12,66,0,0" VerticalAlignment="Top" Width="123"/>
   <Label Content="If your having problems email me&#xD;&#xA;&#xD;&#xA;e-mail: Madbomb122@gmail.com" HorizontalAlignment="Left" Margin="200,10,0,0" VerticalAlignment="Top" Width="190"/>
   <Label Content="&lt;-- with a 'Dev Log' if asked to." HorizontalAlignment="Left" Margin="178,26,0,0" VerticalAlignment="Top"/>
   <Label Content="Please check FAQ on my GitHub before contacting me." HorizontalAlignment="Left" Margin="135,63,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
   <Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,90,0,0" Stroke="Black" VerticalAlignment="Top"/>
   <Label Content="This script lets you set Windows 10's services based on Black Viper's Service &#xD;&#xA;Configurations, your own Service Configuration (If in a proper format), or a backup &#xD;&#xA;of your Service Configurations made by this script.&#xD;&#xA;&#xD;&#xA;This script was created by MadBomb122." HorizontalAlignment="Left" Margin="11,101,0,0" VerticalAlignment="Top" Width="450" Height="91"/></Grid>
  </TabItem>
 </TabControl>
 <Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,0,0,62" Stroke="Black" VerticalAlignment="Bottom"/>
 <Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,0,0,41" Stroke="Black" VerticalAlignment="Bottom"/>
 <Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,0,0,20" Stroke="Black" VerticalAlignment="Bottom"/>
 <Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="255,0,0,0" Stroke="Black" Width="1" Height="20" VerticalAlignment="Bottom"/></Grid>
</Window>
"@

	[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
	$reader = (New-Object System.Xml.XmlNodeReader $xaml)
	$Form = [Windows.Markup.XamlReader]::Load( $reader )
	$xaml.SelectNodes("//*[@Name]") | ForEach-Object{Set-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name) -Scope Script}

	$Runspace = [runspacefactory]::CreateRunspace()
	$PowerShell = [PowerShell]::Create()
	$PowerShell.RunSpace = $Runspace
	$Runspace.Open()
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
	[System.Collections.ArrayList]$VarList = Get-Variable "WPF_*_CB"
	[System.Collections.ArrayList]$CNoteList = Get-Variable "WPF_CustomNote*"
	
	$Script:WinSkuList = @(48,49,98,100,101)

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
		$Script:RunScript = 1
		$Black_Viper = $WPF_ServiceConfig.SelectedIndex + 1
		If($Black_Viper -eq $BVCount) {
			If(!(Test-Path $ServiceConfigFile -PathType Leaf) -And $ServiceConfigFile -ne $null) {
				[Windows.Forms.MessageBox]::Show("The File '$ServiceConfigFile' does not exist","Error", 'OK')
				$Script:RunScript = 0
			} Else {
				$Script:LoadServiceConfig = 1
				$Script:Black_Viper = 0
			}
		}
		If($RunScript -eq 1){ GuiDone } Else{ RunDisableCheck }
	})

	$WPF_ScriptLog_CB.Add_Checked({ $WPF_LogNameInput.IsEnabled = $True })
	$WPF_ScriptLog_CB.Add_UnChecked({ $WPF_LogNameInput.IsEnabled = $False })
	$WPF_CustomBVCB.Add_Checked({ RunDisableCheck ;$WPF_SaveCustomSrvButton.content = "Save Selection" })
	$WPF_CustomBVCB.Add_UnChecked({ RunDisableCheck ;$WPF_SaveCustomSrvButton.content = "Save Current" })
	$WPF_btnOpenFile.Add_Click({ OpenSaveDiaglog 0 })
	$WPF_SaveCustomSrvButton.Add_Click({ OpenSaveDiaglog 1 })
	$WPF_SaveRegButton.Add_Click({ OpenSaveDiaglog 2 })
	$WPF_EMail.Add_Click({ OpenWebsite "mailto:madbomb122@gmail.com" })
	$WPF_BuildCheck_CB.Add_Click({ RunDisableCheck })
	$WPF_EditionCheck_CB.Add_Click({ RunDisableCheck })
	$WPF_BlackViperWSButton.Add_Click({ OpenWebsite "http://www.blackviper.com/" })
	$WPF_Madbomb122WSButton.Add_Click({ OpenWebsite "https://github.com/madbomb122/" })
	$WPF_DonateButton.Add_Click({ OpenWebsite "https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/" })
	$WPF_LoadServicesButton.Add_Click({ GenerateServices })
	$WPF_CopyrightButton.Add_Click({ [Windows.Forms.MessageBox]::Show($CopyrightItems,"Copyright", 'OK') })

	$CopyrightItems = 'Copyright (c) 1999-2017 Charles "Black Viper" Sparks - Services Configuration

The MIT License (MIT)

Copyright (c) 2017 Madbomb122 - Black Viper Service Configuration Script

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'

	$Skip_Services = @(
	"PimIndexMaintenanceSvc_",
	"DevicesFlowUserSvc_",
	"UserDataSvc_",
	"UnistoreSvc_",
	"WpnUserService_",
	"AppXSVC",
	"BrokerInfrastructure",
	"ClipSVC",
	"CoreMessagingRegistrar",
	"DcomLaunch",
	"EntAppSvc",
	"gpsvc",
	"LSM",
	"NgcSvc",
	"NgcCtnrSvc",
	"RpcSs",
	"RpcEptMapper",
	"sppsvc",
	"StateRepository",
	"SystemEventsBroker",
	"Schedule",
	"tiledatamodelsvc",
	"WdNisSvc",
	"SecurityHealthService",
	"msiserver",
	"MpsSvc",
	"WinDefend")
	For($i=0;$i -ne 5;$i++){ $Skip_Services[$i] = $Skip_Services[$i] + $ServiceEnd }

	$Script:CurrServices = Get-Service | Select-Object DisplayName, Name, StartType
	$Script:RunScript = 0
	If($All_or_Min -eq "-full"){ $WPF_RadioAll.IsChecked = $True } Else{ $WPF_RadioMin.IsChecked = $True }
	If($ScriptLog -eq 1) {
		$WPF_ScriptLog_CB.IsChecked = $True
		$WPF_LogNameInput.IsEnabled = $True
	} Else {
		$WPF_LogNameInput.IsEnabled = $False
	}
	If($IsLaptop -eq "-Lap"){ $WPF_ServiceConfig.Items.RemoveAt(2) }
	$Script:BVCount = $WPF_ServiceConfig.Items.Count

	ForEach($Var In $VarList){ If($(Get-Variable -Name ($Var.Name.Split('_')[1]) -ValueOnly) -eq 1){ $Var.Value.IsChecked = $True } Else{ $Var.Value.IsChecked = $False } }

	If($WinEdition -eq "Home" -or $EditionCheck -eq "Home"){ $WPF_EditionConfig.SelectedIndex = 0 } Else{ $WPF_EditionConfig.SelectedIndex = 1 }
	If($EditionCheck -eq "Pro" -or $EditionCheck -eq "Home"){ $WPF_EditionConfig.IsEnabled = $True } Else{ $WPF_EditionCheck_CB.IsChecked = $False }

	$WPF_LoadFileTxtBox.Text = $ServiceConfigFile
	$WPF_LogNameInput.Text = $LogName
	$WPF_Script_Ver_Txt.Text = "$Script_Version.$Minor_Version ($Script_Date)"
	$WPF_Service_Ver_Txt.Text = "$ServiceVersion ($ServiceDate)"
	$WPF_Release_Type_Txt.Text = $Release_Type
	$Script:ServiceImport = 1
	HideCustomSrvStuff
	RunDisableCheck
	Clear-Host
	DisplayOutMenu "Displaying GUI Now" 14 0 1 0
	$Form.ShowDialog() | Out-Null
}

Function RunDisableCheck {
	If($WPF_BuildCheck_CB.IsChecked){ $Script:BuildCheck = 1 } Else{ $Script:BuildCheck = 0 }
	If($WPF_EditionCheck_CB.IsChecked) {
		$Script:EditionCheck = $WPF_EditionConfig.Text
		$WPF_EditionConfig.IsEnabled = $True
	} Else {
		$Script:EditionCheck = 0
		$WPF_EditionConfig.IsEnabled = $False
	}

	$EBFailCount = 0
	If(!($EditionCheck -eq "Home" -or $EditionCheck -eq "Pro" -or $WinSkuList -Contains $WinSku)){ $EBFailCount++ }
	If($Win10Ver -lt $MinVer -And $BuildCheck -ne 1){ $EBFailCount += 2 }

	If($EBFailCount -ne 0) {
		$Buttontxt = "Run Disabled Due to "
		If($EBFailCount -eq 3) {
			$Buttontxt += "Edition & Build"
		} ElseIf($EBFailCount -eq 1) {
			$Buttontxt += "Edition"
		} Else {
			$Buttontxt += "Build"
		}
		$WPF_RunScriptButton.IsEnabled = $False
		$Buttontxt += " Check"
	} ElseIf($WPF_ServiceConfig.SelectedIndex + 1 -eq $BVCount) {
		If(!($ServiceConfigFile) -or !(Test-Path $ServiceConfigFile -PathType Leaf)) { 
			$WPF_RunScriptButton.IsEnabled = $False
			$Buttontxt = "Run Disabled, No Custom Service List File Selected or Doesn't exist."
			$WPF_LoadServicesButton.IsEnabled = $False
		} Else {
			$WPF_LoadServicesButton.IsEnabled = $True
			$Buttontxt = "Run Script with Custom Service List" 
		}
	} Else {
		If($WPF_CustomBVCB.IsChecked){ $Buttontxt = "Run Script with Checked Services" } Else{ $Buttontxt = "Run Script" }
		$WPF_RunScriptButton.IsEnabled = $True
	}
	$WPF_RunScriptButton.content = $Buttontxt
}

Function GuiDone {
	ForEach($Var In $VarList) {
		If($Var.Value.IsChecked){ $SetValue = 1 } Else{ $SetValue = 0 }
		Set-Variable -Name ($Var.Name.Split('_')[1]) -Value $SetValue -Scope Script
	}
	If($WPF_RadioAll.IsChecked){ $Script:All_or_Min = "-full" } Else{ $Script:All_or_Min = "-min" }
	If($WPF_ScriptLog_CB.IsChecked){ $Script:LogName = $WPF_LogNameInput.Text }
	If($WPF_EditionCheck_CB.IsChecked){ $Script:EditionCheck = $WPF_EditionConfig.Text }
	If($WPF_CustomBVCB.IsChecked){ GetCustomBV }

	$Form.Close()
	Black_Viper_Set $Black_Viper $All_or_Min
}

Function GenerateServices {
	$Black_Viper = $WPF_ServiceConfig.SelectedIndex + 1
	If($Black_Viper -eq $BVCount) {
		If($Script:ServiceGen -eq 0){ $Script:ServiceImport = 1 }
		$Script:LoadServiceConfig = 1
		$ServiceFilePath = $WPF_LoadFileTxtBox.Text
		$ServiceGen = 1
	} Else {
		If($Script:ServiceGen -eq 1){ $Script:ServiceImport = 1 }
		If($WPF_RadioAll.IsChecked){ $FullMin = "-Full" } Else{ $FullMin = "-Min" }
		$Script:LoadServiceConfig = 0
		$ServiceFilePath = $filebase + "BlackViper.csv"
		$ServiceGen = 0
	}

	Switch($Black_Viper) {
		{$LoadServiceConfig -eq 1} { $Script:BVService = "StartType" ;Break }
		1 { ($Script:BVService="Def-"+$WinEdition+$FullMin) ;$BVSAlt = "Def-"+$WinEdition+"-Full" ;Break }
		2 { ($Script:BVService="Safe"+$IsLaptop+$FullMin) ;$BVSAlt = "Safe"+$IsLaptop+"-Full" ;Break }
		3 { ($Script:BVService="Tweaked"+$IsLaptop+$FullMin) ;$BVSAlt = "Tweaked"+$IsLaptop+"-Full" ;Break }
	}

	If($WPF_XboxService_CB.IsChecked){ $Script:XboxService = 1 } Else{ $Script:XboxService = 0 }
	If($ServiceImport -eq 1) {
		[System.Collections.ArrayList]$ServCB = Import-Csv $ServiceFilePath
		$ServiceImport = 0
	}
	[System.Collections.ArrayList]$DataGridList = @()

	ForEach($item In $ServCB) {
		$SName = $($item.ServiceName)
		If($SName -Like "*_*"){ $SName = $SName.Split('_')[0] + "_$ServiceEnd" }
		If($CurrServices.Name -Contains $SName) {
			$ServiceTypeNum = $($item.$BVService)
			$ServiceCurrType = ($CurrServices.Where{$_.Name -eq $SName}).StartType
			If($ServiceTypeNum -eq 0) {
				$checkbox = $False
				$ServiceTypeNum = $($item.$BVSAlt)
			} ElseIf($XboxService -eq 1 -and $XboxServiceArr -Contains $SName) {
				$checkbox = $False
			} Else {
				$checkbox = $True
			}
			$ServiceType = $ServicesTypeList[$ServiceTypeNum]
			If($ServiceTypeNum -eq 4){ $ServiceType += " (Delayed Start)" }
			If($SName -Is [system.array]){ $SName = $SName[0] }
			$ServiceCommName = ($CurrServices.Where{$_.Name -eq $SName}).DisplayName
			$DataGridList += New-Object PSObject -Property @{ checkboxChecked = $checkbox ;CName=$ServiceCommName ;ServiceName = $SName ;CurrType = $ServiceCurrType ;BVType = $ServiceType ;StartType = $ServiceTypeNum }
		}
	}
	$WPF_dataGrid.ItemsSource = $DataGridList
	$WPF_dataGrid.Items.Refresh()

	If(!($ServicesGenerated)) {
		$WPF_ServiceClickLabel.Visibility = 'Hidden'
		$WPF_ServiceLegendLabel.Visibility = 'Visible'
		$WPF_ServiceNote.Visibility = 'Visible'
		$WPF_CustomBVCB.Visibility = 'Visible'
		$WPF_SaveCustomSrvButton.Visibility = 'Visible'
		$WPF_SaveRegButton.Visibility = 'Visible'
		$WPF_LoadServicesButton.content = "Reload"
		$Script:ServicesGenerated = $True
	}
}

Function GetCustomBV {
	$Script:LoadServiceConfig = 2
	[System.Collections.ArrayList]$Script:csvTemp = @()
	$ServiceCBList = $WPF_dataGrid.Items.Where({$_.checkboxChecked -eq $true})
	ForEach($item In $ServiceCBList){ $Script:csvTemp+= New-Object PSObject -Property @{ ServiceName = $item.ServiceName ;StartType = $item.StartType } }
	[System.Collections.ArrayList]$Script:csv = $Script:csvTemp
}

##########
# GUI -End
##########

Function LoadWebCSV([Int]$ErrorChoice) {
	If($ErrorChoice -eq 0){
		$Script:ErrorDi = "Missing File BlackViper.csv -LoadCSV"
		$Pick = " is Missing.             "
	} ElseIf($ErrorChoice -eq 1) {
		$Script:ErrorDi = "Invalid/Corrupt BlackViper.csv"
		$Pick = " is Invalid or Corrupt.  "
	} Else {
		$Script:ErrorDi = "BlackViper.csv Not Valid for current Update"
		$Pick = " needs to be Updated.    "
	}
	While($LoadWebCSV -ne "Out") {
		Error_Top_Display
		LeftLine ;DisplayOutMenu " The File " 2 0 0 ;DisplayOutMenu "BlackViper.csv" 15 0 0 ;DisplayOutMenu "$Pick" 2 0 0 ;RightLine
		MenuBlankLine
		LeftLine ;DisplayOutMenu " Do you want to download " 2 0 0 ;DisplayOutMenu "BlackViper.csv" 15 0 0 ;DisplayOutMenu "?         " 2 0 0 ;RightLine
		MenuBlankLine
		MenuLine
		$Invalid = ShowInvalid $Invalid
		$LoadWebCSV = Read-Host "`nDownload? (Y)es/(N)o"
		Switch($LoadWebCSV.ToLower()) {
			{ $_ -eq "n" -or $_ -eq "no" } { DisplayOutMenu "For download manually save the following " 2 0 1 ;DisplayOutMenu "https://github.com/madbomb122/BlackViperScript/raw/master/BlackViper.csv" 15 0 0 ;Exit ;Break }
			{ $_ -eq "y" -or $_ -eq "yes" } { DownloadFile $Service_Url $ServiceFilePath ;$LoadWebCSV = "Out" ;Break }
			Default { $Invalid = 1 ;Break }
		}
	}
	If($ErrorChoice -In 1..2){ [System.Collections.ArrayList]$Script:csv = Import-Csv $ServiceFilePath }
	CheckBVcsv
	Return
}

Function ServiceBAfun([String]$ServiceBA) {
	If($LogBeforeAfter -eq 1) {
		$ServiceBAFile = $filebase + $ServiceBA + ".log"
		If($ServiceBA -eq "Services-Before"){ $CurrServices | Out-File $ServiceBAFile } Else{ Get-Service | Select-Object DisplayName, StartType | Out-File $ServiceBAFile }
		Get-Service | Select-Object DisplayName, StartType | Out-File $ServiceBAFile
	} ElseIf($LogBeforeAfter -eq 2) {
		If($ServiceBA -eq "Services-Before"){ $TMPServices = $CurrServices } Else{ $TMPServices = Get-Service | Select-Object DisplayName, Name, StartType }
		Write-Output "`n$ServiceBA -Start" 4>&1 | Out-File -Filepath $LogFile -Append
		Write-Output "-------------------------------------" 4>&1 | Out-File -Filepath $LogFile -Append
		Write-Output $TMPServices 4>&1 | Out-File -Filepath $LogFile -Append
		Write-Output "-------------------------------------" 4>&1 | Out-File -Filepath $LogFile -Append
		Write-Output "$ServiceBA -End" 4>&1 | Out-File -Filepath $LogFile -Append
		Write-Output " " 4>&1 | Out-File -Filepath $LogFile -Append
	}
}

Function Save_Service([String]$SavePath) {
	$ServiceSavePath = $filebase + $Env:computername
	$SaveService = @()

	If($WPF_CustomBVCB.IsChecked) {
		$ServiceSavePath += "-Custom-Service.csv"
		$ServiceCBList = $WPF_dataGrid.Items.Where({$_.checkboxChecked -eq $true})
		ForEach($item In $ServiceCBList) {
			$ServiceName = $item.ServiceName
			If($ServiceName -Like "*_*"){ $ServiceName = $ServiceName.Split('_')[0] + "?????" }
			$SaveService += New-Object PSObject -Property @{ ServiceName = $ServiceName ;StartType = $item.StartType }
		}
	} Else {
		If($AllService -eq $null) { 
			$ServiceSavePath += "-Service-Backup.csv"
			$AllService = Get-Service | Select-Object Name, StartType
		} Else {
			$ServiceSavePath += "-Custom-Service.csv"
		}
		ForEach($Service In $AllService) {
			$ServiceName = $Service.Name
			If(!($Skip_Services -Contains $ServiceName)) {
				Switch("$($Service.StartType)") {
					"Disabled" { $StartType = 1 ;Break }
					"Manual" { $StartType = 2 ;Break }
					"Automatic" { $exists = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName\").DelayedAutostart ;If($exists -eq 1){ $StartType = 4 } Else{ $StartType = 3 } ;Break }
					Default { $StartType = "$($Service.StartType)" ;Break }
				}
				If($ServiceName -Like "*_*"){ $ServiceName = $ServiceName.Split('_')[0] + "?????" }
				$SaveService += New-Object PSObject -Property @{ ServiceName = $ServiceName ;StartType = $StartType }
			}
		}
	}
	If($SavePath -ne $null){ $ServiceSavePath = $SavePath}
	$SaveService | Export-Csv -LiteralPath $ServiceSavePath -encoding "unicode" -force -Delimiter ","
	If($SavePath -ne $null){ [Windows.Forms.MessageBox]::Show("File saved as '$SavePath'","File Saved", 'OK') }
}

Function ServiceSet([String]$BVService) {
	Clear-Host
	If(!($CurrServices)){ $Script:CurrServices = Get-Service | Select-Object DisplayName, Name, StartType }
	$NetTCP = @("NetMsmqActivator","NetPipeActivator","NetTcpActivator")
	If($LogBeforeAfter -eq 2) { DiagnosticCheck 1 }
	ServiceBAfun "Services-Before"
	If($DryRun -ne 1){ DisplayOut "Changing Service Please wait..." 14 0 } Else{ DisplayOut "List of Service that would be changed on Non-Dryrun..." 14 0 }
	DisplayOut "Service_Name - Current -> Change_To" 14 0
	DisplayOut "-------------------------------------" 14 0
	ForEach($item In $csv) {
		$ServiceTypeNum = $($item.$BVService)
		$ServiceName = $($item.ServiceName)
		$ServiceCommName = ($CurrServices.Where{$_.Name -eq $ServiceName}).DisplayName
		If($ServiceTypeNum -eq 0 -And $ShowSkipped -eq 1) {
			If($ServiceCommName -ne $null){ $DispTemp = "Skipping $ServiceCommName ($ServiceName)" } Else{ $DispTemp = "Skipping $ServiceName" }
			DisplayOut $DispTemp  14 0
		} ElseIf($ServiceTypeNum -ne 0) {
			If($ServiceName -Like "*_*"){ $ServiceName = $ServiceName.Split('_')[0] + "_$ServiceEnd" }
			$ServiceType = $ServicesTypeList[$ServiceTypeNum]
			$ServiceCurrType = ServiceCheck $ServiceName $ServiceType
			If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
			If($ServiceCurrType -eq "Xbox") {
				$DispTemp = "$ServiceCommName ($ServiceName) is an Xbox Service and will be skipped"
				DisplayOut $DispTemp  2 0
			} ElseIf($ServiceCurrType -ne $False -And $ServiceCurrType -ne "Already") {
				$DispTemp = "$ServiceCommName ($ServiceName) - $ServiceCurrType -> $ServiceType"
				If($ServiceTypeNum -In 1..4 -And $DryRun -ne 1){ Set-Service $ServiceName -StartupType $ServiceType }
				If($ServiceTypeNum -eq 4) {
					$DispTemp += " (Delayed Start)"
					If($DryRun -ne 1){ Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\$ServiceName\" -Name "DelayedAutostart" -Type DWord -Value 1 }
				}
				DisplayOut $DispTemp  11 0
			} ElseIf($ServiceCurrType -eq "Already" -And $ShowAlreadySet -eq 1) {
				$DispTemp = "$ServiceCommName ($ServiceName) is already $ServiceType"
				If($ServiceTypeNum -eq 4){ $DispTemp += " (Delayed Start)" }
				DisplayOut $DispTemp  15 0
			} ElseIf($ServiceCurrType -eq $False -And $ShowNonInstalled -eq 1) {
				$DispTemp = "No service with name $ServiceName"
				DisplayOut $DispTemp  13 0
			}
		}
	}
	DisplayOut "-------------------------------------" 14 0
	If($DryRun -ne 1){ DisplayOut "Service Changed..." 14 0 } Else{ DisplayOut "List of Service Done..." 14 0 }
	ServiceBAfun "Services-After"
	AutomatedExitCheck 1
}

Function RegistryServiceFile([String]$TempFP) {
	$ServiceCBList = $WPF_dataGrid.Items.Where({$_.checkboxChecked -eq $true})
	Write-Output "Windows Registry Editor Version 5.00" | Out-File -Filepath $TempFP
	Write-Output "" | Out-File -Filepath $TempFP -Append

	ForEach($item In $ServiceCBList) {
		$ServiceTypeNum = $item.StartType
		$ServiceName = $item.ServiceName
		If($ServiceTypeNum -ne 0) {
			If($ServiceName -Like "*_*"){ $ServiceName = $ServiceName.Split('_')[0] + "_$ServiceEnd" }
			If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
			If(!($ServiceCurrType -eq "Xbox")) {
				$Num = '"Start"=dword:0000000' + $ServicesRegTypeList[$ServiceTypeNum]
				Write-Output "[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\$ServiceName]" | Out-File -Filepath $TempFP -Append
				Write-Output "$Num" | Out-File -Filepath $TempFP -Append
				If($ServiceTypeNum -eq 4) { Write-Output '"DelayedAutostart"=dword:00000001' | Out-File -Filepath $TempFP -Append }
				Write-Output "" | Out-File -Filepath $TempFP -Append
			}
		}
	}
	[Windows.Forms.MessageBox]::Show("Registry File saved as '$TempFP'","File Saved", 'OK')
}

Function ServiceCheck([String]$S_Name,[String]$S_Type) {
	If($CurrServices.Name -Contains $S_Name) {
		If($XboxService -eq 1 -and $XboxServiceArr -Contains $S_Name) { Return "Xbox" }
		$C_Type = ($CurrServices.Where{$_.Name -eq $S_Name}).StartType
		If($S_Type -ne $C_Type) {
			If($S_Name -eq 'lfsvc' -And $C_Type -eq 'disabled' -And (Test-Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3")) {
				Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\TriggerInfo\3" -Recurse -Force
			} ElseIf($S_Name -eq 'NetTcpPortSharing') {
				If($NetTCP -Contains $CurrServices.Name){ Return "Manual" } Return $False
			}
			Return $C_Type
		}
		Return "Already"
	}
	Return $False
}

Function Black_Viper_Set([Int]$BVOpt,[String]$FullMin) {
	PreScriptCheck
	Switch($BVOpt) {
		{$LoadServiceConfig -In 1..2} { ServiceSet "StartType" ;Break }
		1 { ServiceSet ("Def"+$WinEdition+$FullMin) ;Break }
		2 { ServiceSet ("Safe"+$IsLaptop+$FullMin) ;Break }
		3 { ServiceSet ("Tweaked"+$IsLaptop+$FullMin) ;Break }
	}
}

Function InternetCheck { If($InternetCheck -eq 1 -or (Test-Connection -Computer GitHub.com -Count 1 -Quiet)){ Return $True } Return $False }

Function CreateLog {
	If($DevLog -eq 1) {
		$Script:ScriptLog = 1
		$Script:LogName = "Dev-Log.log"
		$Script:Diagnostic = 1
		$Script:Automated = 0
		$Script:LogBeforeAfter = 2
		$Script:DryRun = 1
		$Script:AcceptToS = "Accepted-Dev-Switch"
		$Script:ShowNonInstalled = 1
		$Script:ShowSkipped = 1
		$Script:ShowAlreadySet = 1
	}

	If($ScriptLog -ne 0) {
		$Script:LogFile = $filebase + $LogName
		$Time = Get-Date -Format g
		If($ScriptLog -eq 2) {
			Write-Output "Updated Script File running" 4>&1 | Out-File -Filepath $LogFile -NoNewline -Append
			Write-Output "--Start of Log ($Time)--" | Out-File -Filepath $LogFile -NoNewline -Append
			$ScriptLog = 1
		} Else{
			Write-Output "--Start of Log ($Time)--" | Out-File -Filepath $LogFile
		}
	}
	$Script:LogStarted = 1
}

Function PreScriptCheck {
	If($RunScript -eq 0){ Exit }
	If($LogStarted -eq 0) { CreateLog }
	$EBCount = 0

	If($EditionCheck -eq "Home" -or $WinSku -In 100..101 -or $WinSku -eq 98) {
		$Script:WinEdition = "-Home"
	} ElseIf($EditionCheck -eq "Pro" -or $WinSku -In 48..49) {
		$Script:WinEdition = "-Pro"
	} Else {
		$Script:ErrorDi = "Edition"
		$EditionCheck = "Fail"
		$EBCount++
	}

	If($Win10Ver -lt $MinVer -And $BuildCheck -ne 1) {
		If($EditionCheck -eq "Fail"){ $Script:ErrorDi += " & Build" } Else{ $Script:ErrorDi = "Build" }
		$Script:ErrorDi += " Check Failed"
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
			LeftLineLog ;DisplayOutMenu " You are using " 2 0 0 1;DisplayOutMenu ("$FullWinEdition" +(" "*(34-$FullWinEdition.Length))) 15 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " SKU # " 2 0 0 1;DisplayOutMenu ("$WinSku" +(" "*(42-$WinSku.Length))) 15 0 0 1 ;RightLineLog
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu " If you are using Home or Pro...                  " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " Please contact me with                           " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 1. What Edition you are using                    " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 2. What Edition it says you are using            " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 3. The SKU # listed above                        " 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu " To skip use one of the following methods        " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 1. Change " 2 0 0 1 ;DisplayOutMenu "EditionCheck" 15 0 0 1 ;DisplayOutMenu " in script file          " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 2. Change " 2 0 0 1 ;DisplayOutMenu "Skip_EditionCheck" 15 0 0 1 ;DisplayOutMenu " to " 2 0 0 1 ;DisplayOutMenu "=yes" 15 0 0 1 ;DisplayOutMenu " in bat file" 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 3. Run Script or Bat file with " 2 0 0 1 ;DisplayOutMenu "-secp" 15 0 0 1 ;DisplayOutMenu " argument   " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 4. Run Script or Bat file with " 2 0 0 1 ;DisplayOutMenu "-sech" 15 0 0 1 ;DisplayOutMenu " argument   " 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			MenuLineLog
		}
		If($BuildCheck -eq "Fail") {
			$EBCount++
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu " $EBCount. Not a valid Build for this Script.           " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " Lowest Build Recommended is Creator's Update    " 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu " You are using Build " 2 0 0 1 ;DisplayOutMenu ("$BuildVer" +(" "*(24-$BuildVer.Length))) 15 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " You are using Version " 2 0 0 1 ;DisplayOutMenu ("$Win10Ver" +(" "*(23-$BuildVer.Length))) 15 0 0 1 ;RightLineLog
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu " To skip use one of the following methods		" 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 1. Change " 2 0 0 1 ;DisplayOutMenu "BuildCheck" 15 0 0 1 ;DisplayOutMenu " to " 2 0 0 1 ;DisplayOutMenu "=1" 15 0 0 1 ;DisplayOutMenu " in script file	  " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 2. Change " 2 0 0 1 ;DisplayOutMenu "Skip_BuildCheck" 15 0 0 1 ;DisplayOutMenu " to " 2 0 0 1 ;DisplayOutMenu "=yes" 15 0 0 1 ;DisplayOutMenu " in bat file  " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 3. Run Script or Bat file with " 2 0 0 1 ;DisplayOutMenu "-sbc" 15 0 0 1 ;DisplayOutMenu " argument	" 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			MenuLineLog
		}
		AutomatedExitCheck 1
	}
	If($BackupServiceConfig -eq 1){ Save_Service }
	If($LoadServiceConfig -eq 1) {
		$ServiceFilePath = $ServiceConfigFile
		If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
			$Script:ErrorDi = "Missing File $ServiceConfigFile"
			Error_Top_Display
			LeftLineLog ;DisplayOutMenu "The File " 2 0 0 1 ;DisplayOutMenu ("$ServiceConfigFile" +(" "*(28-$DFilename.Length))) 15 0 0 1 ;DisplayOutMenu " is missing." 2 0 0 1 ;RightLineLog
			Error_Bottom
		}
		$ServiceVerCheck = 0
	} ElseIf($LoadServiceConfig -eq 2) {
	} Else {
		$ServiceFilePath = $filebase + "BlackViper.csv"
		If(!(Test-Path $ServiceFilePath -PathType Leaf)) {
			If($ServiceVerCheck -eq 0) {
				If($ScriptLog -eq 1){ Write-Output "Missing File 'BlackViper.csv'" | Out-File -Filepath $LogFile }
				LoadWebCSV 0
			} Else {
				If($ScriptLog -eq 1){ Write-Output "Downloading Missing File 'BlackViper.csv'" | Out-File -Filepath $LogFile }
				DownloadFile $Service_Url $ServiceFilePath
			}
			$ServiceVerCheck = 0
		}
	}
	If($LoadServiceConfig -ne 2){ [System.Collections.ArrayList]$Script:csv = Import-Csv $ServiceFilePath }
	If($ScriptVerCheck -eq 1 -or $ServiceVerCheck -eq 1) {
		If(InternetCheck) {
			$VersionFile = $Env:Temp + "\Temp.csv"
			DownloadFile $Version_Url $VersionFile
			$CSV_Ver = Import-Csv $VersionFile
			Remove-Item $VersionFile
			If($LoadServiceConfig -eq 0 -And $ServiceVerCheck -eq 1 -And $($CSV_Ver[1].Version) -gt $($csv[0]."Def-Home-Full")) {
				If($ScriptLog -eq 1){ Write-Output "Downloading update for 'BlackViper.csv'" | Out-File -Filepath $LogFile }
				DownloadFile $Service_Url $ServiceFilePath
				If($LoadServiceConfig -ne 2){ [System.Collections.ArrayList]$Script:csv = Import-Csv $ServiceFilePath }
			}
			If($ScriptVerCheck -eq 1) {
				If($Release_Type -eq "Stable"){ $CSVLine = 0 } Else{ $CSVLine = 3 }
				$WebScriptVer = $($CSV_Ver[$CSVLine].Version)
				$WebScriptMinorVer =  $($CSV_Ver[$CSVLine].MinorVersion)
				If(($WebScriptVer -gt $Script_Version) -or ($WebScriptVer -eq $Script_Version -And $WebScriptMinorVer -gt $Minor_Version)){ ScriptUpdateFun } 
			}
		} Else {
			$Script:ErrorDi = "No Internet"
			Error_Top_Display
			LeftLineLog ;DisplayOutMenu " Update Failed Because no Internet was detected. " 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu " Tested by pinging GitHub.com                    " 2 0 0 1 ;RightLineLog
			MenuBlankLineLog
			LeftLineLog ;DisplayOutMenu " To skip use one of the following methods        " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 1. Change " 2 0 0 1 ;DisplayOutMenu "InternetCheck" 15 0 0 1 ;DisplayOutMenu " to " 2 0 0 1 ;DisplayOutMenu "=1" 15 0 0 1 ;DisplayOutMenu " in script file   " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 2. Change " 2 0 0 1 ;DisplayOutMenu "InternetCheck" 15 0 0 1 ;DisplayOutMenu " to " 2 0 0 1 ;DisplayOutMenu "=no" 15 0 0 1 ;DisplayOutMenu " in bat file     " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu " 3. Run Script or Bat file with " 2 0 0 1 ;DisplayOutMenu "-sic" 15 0 0 1 ;DisplayOutMenu " argument    " 2 0 0 1 ;RightLineLog
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
	If($LoadServiceConfig -ne 2){ CheckBVcsv ;$csv.RemoveAt(0) }
}

Function CheckBVcsv {
	If(($csv[0]."Def-Pro-Full") -ne "GernetatedByMadBomb122") {
		If($Automated -ne 1){
			LoadWebCSV 1
		} Else {
			Error_Top_Display
			LeftLineLog ;DisplayOutMenu "The File " 2 0 0 1 ;DisplayOutMenu "BlackViper.csv" 15 0 0 1 ;DisplayOutMenu " is Invalid or Corrupt.   " 2 0 0 1 ;RightLineLog
			Error_Bottom
		}
	} ElseIf(!(Test-Path $ServiceFilePath -PathType Leaf)) {
		$Script:ErrorDi = "Missing File BlackViper.csv"
		Error_Top_Display
		LeftLineLog ;DisplayOutMenu "The File " 2 0 0 1 ;DisplayOutMenu "BlackViper.csv" 15 0 0 1 ;DisplayOutMenu " is missing and couldn't  " 2 0 0 1 ;RightLineLog
		LeftLineLog ;DisplayOutMenu "couldn't download for some reason.               " 2 0 0 1 ;RightLineLog
		Error_Bottom
	} 
	$Script:ServiceVersion = ($csv[0]."Def-Home-Full")
	$Script:ServiceDate = ($csv[0]."Def-Home-Min")
}

Function UpdateDisplay([String]$FullVer,[String]$DFilename) {
	Clear-Host
	MenuLineLog
	LeftLineLog ;DisplayOutMenu "                  Update Found!                  " 13 0 0 1 ;RightLineLog
	MenuLineLog
	MenuBlankLineLog
	LeftLineLog ;DisplayOutMenu "Downloading version " 15 0 0 1 ;DisplayOutMenu ("$FullVer" + (" "*(29-$FullVer.Length))) 11 0 0 1 ;RightLineLog
	LeftLineLog ;DisplayOutMenu "Will run " 15 0 0 1 ;DisplayOutMenu ("$DFilename" +(" "*(40-$DFilename.Length))) 11 0 0 1 ;RightLineLog
	LeftLineLog ;DisplayOutMenu "after download is complete.                      " 2 0 0 1 ;RightLineLog
	MenuBlankLineLog
	MenuLineLog
}

Function ScriptUpdateFun {
	$FullVer = "$WebScriptVer.$WebScriptMinorVer"
	$UpdateFile = $filebase + "Update.bat"
	$UpArg = ""

	If($Automated -eq 1){ $UpArg += "-auto " }
	If($AcceptToS -ne 0){ $UpArg += "-atosu " }
	If($ServiceVerCheck -eq 1){ $UpArg += "-use " }
	If($InternetCheck -eq 1){ $UpArg += "-sic " }
	If($EditionCheck -eq "Home"){ $UpArg += "-sech " }
	If($EditionCheck -eq "Pro"){ $UpArg += "-secp " }
	If($BuildCheck -eq 1){ $UpArg += "-sbc " }
	If($Black_Viper -eq 1){ $UpArg += "-default " }
	If($Black_Viper -eq 2){ $UpArg += "-safe " }
	If($Black_Viper -eq 3){ $UpArg += "-tweaked " }
	If($Diagnostic -eq 1){ $UpArg += "-diag " }
	If($LogBeforeAfter -eq 1){ $UpArg += "-baf " }
	If($DryRun -eq 1){ $UpArg += "-dry " }
	If($ShowNonInstalled -eq 1){ $UpArg += "-snis " }
	If($ShowSkipped -eq 1){ $UpArg += "-sss " }
	If($DevLog -eq 1){ $UpArg += "-devl " }
	If($ScriptLog -eq 1){ $UpArg += "-logc $LogName " }
	If($All_or_Min -eq "-full"){ $UpArg += "-all " } Else{ $UpArg += "-min " }
	If($XboxService -eq 1){ $UpArg += "-sxb " }
	If($BackupServiceConfig -eq 1){ $UpArg += "-bcsc " }
	If($ShowNonInstalled -eq 1){ $UpArg += "-snis " }
	If($LoadServiceConfig -eq 1){ $UpArg += "-lcsc $ServiceConfigFile " }
	If($LoadServiceConfig -eq 2) {
		$TempSrv = $Env:Temp + "\TempSrv.csv"
		$Script:csv | Export-Csv -LiteralPath $TempSrv -Encoding "unicode" -Force -Delimiter ","
		$UpArg += "-lcsc $TempSrv "
	} 

	If(Test-Path $UpdateFile -PathType Leaf) {
		$DFilename = "BlackViper-Win10.ps1"
		$UpArg += "-u -bv "
		If($Release_Type -ne "Stable"){ $UpArg += "-test " }
		UpdateDisplay $FullVer $DFilename
		cmd.exe /c "$UpdateFile $UpArg"
	} Else {
		$DFilename = "BlackViper-Win10-Ver." + $FullVer
		If($Release_Type -ne "Stable") {
			$DFilename += "-Testing"
			$Script_Url = $URL_Base + "Testing/"
		}
		$DFilename += ".ps1"
		$Script_Url = $URL_Base + "BlackViper-Win10.ps1"
		$WebScriptFilePath = $filebase + $DFilename
		UpdateDisplay $FullVer $DFilename
		DownloadFile $Script_Url $WebScriptFilePath
		If($BatUpdateScriptFileName -eq 1) {
			$BatFile = $filebase + "_Win10-BlackViper.bat"
			If(Test-Path $BatFile -PathType Leaf) {
				(Get-Content -LiteralPath $BatFile) | Foreach-Object {$_ -replace "Set Script_File=.*?$" , "Set Script_File=$DFilename"} | Set-Content -LiteralPath $BatFile -Force
				MenuBlankLineLog
				LeftLineLog ;DisplayOutMenu " Updated bat file with new script file name.     " 13 0 0 1 ;RightLineLog
				MenuBlankLineLog
				MenuLineLog
			}
		}
		Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$WebScriptFilePath`" $UpArg" -Verb RunAs
	}
	Exit
}

Function GetArgs {
	For($i=0; $i -lt $PassedArg.Length; $i++) {
		If($PassedArg[$i].StartsWith("-")) {
			Switch($PassedArg[$i]) {
				"-default" { $Script:Black_Viper = 1 ;$Script:BV_ArgUsed = 2 ;Break }
				"-safe" { $Script:Black_Viper = 2 ;$Script:BV_ArgUsed = 2;Break }
				"-tweaked" { If($IsLaptop -ne "-Lap"){ $Script:Black_Viper = 3 ;$Script:BV_ArgUsed = 2 } Else{ $Script:BV_ArgUsed = 1 } ;Break }
				"-all" { $Script:All_or_Min = "-full" ;Break }
				"-min" { $Script:All_or_Min = "-min" ;Break }
				"-log" { $Script:ScriptLog = 1 ;If(!($PassedArg[$i+1].StartsWith("-"))){ $Script:LogName = $PassedArg[$i+1] ;$i++ } ;Break }
				"-logc" { $Script:ScriptLog = 2 ;If(!($PassedArg[$i+1].StartsWith("-"))){ $Script:LogName = $PassedArg[$i+1] ;$i++ } ;Break } #To append to logfile (used for update)
				"-lcsc" { $Script:BV_ArgUsed = 3 ;$Script:LoadServiceConfig = 1 ;If(!($PassedArg[$i+1].StartsWith("-"))){ $Script:ServiceConfigFile = $PassedArg[$i+1] ;$i++ } ;Break }
				"-bcsc" { $Script:BackupServiceConfig = 1 ;Break }
				"-baf" { $Script:LogBeforeAfter = 1 ;Break }
				"-snis" { $Script:ShowNonInstalled = 1 ;Break }
				"-sss" { $Script:ShowSkipped = 1 ;Break }
				"-sic" { $Script:InternetCheck = 1 ;Break }
				"-usc" { $Script:ScriptVerCheck = 1 ;Break }
				"-use" { $Script:ServiceVerCheck = 1 ;Break }
				"-atos" { $Script:AcceptToS = "Accepted-Switch" ;Break }
				"-atosu" { $Script:AcceptToS = "Accepted-Update" ;Break }
				"-auto" { $Script:Automated = 1 ;$Script:AcceptToS = "Accepted-Automated-Switch" ;Break }
				"-dry" { $Script:DryRun = 1 ;$Script:ShowNonInstalled = 1 ;Break }
				"-diag" { $Script:Diagnostic = 1 ;$Script:Automated = 0 ;Break }
				"-diagf" { $Script:Diagnostic = 2 ;$Script:Automated = 0 ;Break } # Forces Diag Output
				"-devl" { $Script:DevLog = 1 ;Break }
				"-sbc" { $Script:BuildCheck = 1 ;Break }
				"-sech" { $Script:EditionCheck = "Home" ;Break }
				"-sxb" { $Script:XboxService = 1 ;Break }
				{$_ -eq "-secp" -or $_ -eq "-sec"} { $Script:EditionCheck = "Pro" ;Break }
				{$_ -eq "-help" -or $_ -eq "-h"} { ShowHelp ;Break }
			}
		}
	}
}

Function ShowHelp {
	Clear-Host
	DisplayOut "                  List of Switches                   " 13 0
	DisplayOut "-----------------------------------------------------" 14 0
	DisplayOut "" 13 0
	DisplayOut "-- Basic Switches --" 2 0
	DisplayOutMenu " Switch " 15 0 0 ;DisplayOut "          Description of Switch" 14 0
	DisplayOutMenu "  -atos " 15 0 0 ;DisplayOut "           Accepts ToS " 14 0
	DisplayOutMenu "  -auto " 15 0 0 ;DisplayOut "           Implies -atos...Runs the script to be Automated.. Closes on - User Input, Errors, or End of Script " 14 0
	DisplayOut "" 13 0
	DisplayOut "--Service Configuration Switches--" 2 0
	DisplayOutMenu " Switch " 15 0 0 ;DisplayOut "          Description of Switch" 14 0
	DisplayOutMenu "  -default  " 15 0 0 ;DisplayOut "       Runs the script with Services to Default Configuration " 14 0
	DisplayOutMenu "  -safe " 15 0 0 ;DisplayOut "           Runs the script with Services to Black Viper's Safe Configuration " 14 0
	DisplayOutMenu "  -tweaked " 15 0 0 ;DisplayOut "        Runs the script with Services to Black Viper's Tweaked Configuration " 14 0
	DisplayOutMenu "  -lcsc " 15 0 0 ;DisplayOutMenu "File.csv " 11 0 0 ;DisplayOutMenu "  Loads Custom Service Configuration, " 14 0 0 ;DisplayOutMenu "File.csv" 11 0 0 ;DisplayOut " = Name of your backup/custom file " 14 0
	DisplayOut "" 13 0
	DisplayOut "--Service Choice Switches--" 2 0
	DisplayOutMenu " Switch "  15 0 0 ;DisplayOut "          Description of Switch" 14 0
	DisplayOutMenu "  -all " 15 0 0 ;DisplayOut "            Every windows services will change " 14 0
	DisplayOutMenu "  -min " 15 0 0 ;DisplayOut "            Just the services different from the default to safe/tweaked list " 14 0
	DisplayOut "" 13 0
	DisplayOut "--Update Switches--" 2 0
	DisplayOutMenu " Switch " 15 0 0 ;DisplayOut "          Description of Switch" 14 0
	DisplayOutMenu "  -usc  " 15 0 0 ;DisplayOut "           Checks for Update to Script file before running " 14 0
	DisplayOutMenu "  -use  " 15 0 0 ;DisplayOut "           Checks for Update to Service file before running " 14 0
	DisplayOutMenu "  -sic  " 15 0 0 ;DisplayOut "           Skips Internet Check, if you can't ping GitHub.com for some reason " 14 0
	DisplayOut "" 13 0	
	DisplayOut "--Log Switches--" 2 0
	DisplayOutMenu " Switch " 15 0 0 ;DisplayOut "          Description of Switch" 14 0
	DisplayOutMenu "  -log " 15 0 0 ;DisplayOut "            Makes a log file Script.log " 14 0
	DisplayOutMenu "  -baf " 15 0 0 ;DisplayOut "            Log File of Services Configuration Before and After the script " 14 0
	DisplayOut "" 13 0
	DisplayOut "--AT YOUR OWN RISK Switches--" 13 0
	DisplayOutMenu " Switch " 15 0 0 ;DisplayOut "          Description of Switch" 14 0
	DisplayOutMenu "  -sec  " 15 0 0 ;DisplayOut "           Skips Edition Check by Setting Edition as Pro " 14 0
	DisplayOutMenu "  -secp  " 15 0 0 ;DisplayOut "          ^Same as Above" 14 0
	DisplayOutMenu "  -sech  " 15 0 0 ;DisplayOut "          Skips Edition Check by Setting Edition as Home" 14 0
	DisplayOutMenu "  -sbc  " 15 0 0 ;DisplayOut "           Skips Build Check " 14 0
	DisplayOut "" 13 0
	DisplayOut "--Misc Switches--" 2 0
	DisplayOutMenu " Switch " 15 0 0 ;DisplayOut "          Description of Switch" 14 0
	DisplayOutMenu "  -sxb  " 15 0 0 ;DisplayOut "           Skips changes to all XBox Services " 14 0
	DisplayOutMenu "  -bcsc  " 15 0 0 ;DisplayOut "          Backup Current Service Configuration " 14 0
	DisplayOutMenu "  -dry  " 15 0 0 ;DisplayOut "           Runs the script and shows what services will be changed " 14 0
	DisplayOutMenu "  -diag  " 15 0 0 ;DisplayOut "          Shows diagnostic information, Stops -auto " 14 0
	DisplayOutMenu "  -snis  " 15 0 0 ;DisplayOut "          Show not installed Services " 14 0
	Write-Host "`nPress Any key to Close..." -ForegroundColor White -BackgroundColor Black
	$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC") | out-null
	Exit
}

Function ArgsAndVarSet {
	$Script:IsLaptop = LaptopCheck
	If($PassedArg.Length -gt 0){ GetArgs }

	$Script:WinSku = (Get-WmiObject Win32_OperatingSystem).OperatingSystemSKU
	# 48 = Pro, 49 = Pro N
	# 98 = Home N, 100 = Home (Single Language), 101 = Home

	$Script:FullWinEdition = (Get-WmiObject Win32_OperatingSystem).Caption
	$Script:WinEdition = $FullWinEdition.Split(' ')[-1]
	# Pro or Home

	# https://en.wikipedia.org/wiki/Windows_10_version_history

	$Script:MinBuild = 15063
	$Script:BuildVer = [Environment]::OSVersion.Version.build
	# 16299 = Fall Creators Update
	# 15063 = Creators Update
	# 14393 = Anniversary Update
	# 10586 = First Major Update
	# 10240 = First Release

	$Script:MinVer = 1703
	$Script:Win10Ver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).ReleaseId
	# 1709 = Fall Creators Update
	# 1703 = Creators Update
	# 1607 = Anniversary Update
	# 1511 = First Major Update
	# 1507 = First Release

	If($Diagnostic -eq 2){
		Clear-Host
		DiagnosticCheck 1
		Exit
	}
	If($BV_ArgUsed -eq 1) {
		CreateLog
		Error_Top_Display
		$Script:ErrorDi = "Tweaked + Laptop (Not supported ATM)"
		If($Automated -eq 1){ LeftLineLog ;DisplayOutMenu "Script is set to Automated and...                " 2 0 0 1 ;RightLineLog }
		LeftLineLog ;DisplayOutMenu "Laptops can't use Tweaked option ATM.            " 2 0 0 1 ;RightLineLog
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
		$Script:ErrorDi = "Automated Selected, No Service Selected"
		Error_Top_Display
		LeftLineLog ;DisplayOutMenu "Script is set to Automated and no Service        " 2 0 0 1 ;RightLineLog
		LeftLineLog ;DisplayOutMenu "Configuration option was selected.               " 2 0 0 1 ;RightLineLog
		Error_Bottom
	} Else {
		If($AcceptToS -ne 0){
			$Script:RunScript = 1
			GuiStart
		} Else {
			TOS
		}
	}
}

#--------------------------------------------------------------------------
# Edit values (Option) to your preferance

# Function = Option             #Choices
$Script:AcceptToS = 0           #0 = See ToS, Anything else = Accept ToS

$Script:Automated = 0           #0 = Pause on - User input, On Errors, or End of Script, 1 = Close on
# Automated = 1, Implies that you accept the "ToS"

$Script:BackupServiceConfig = 0 #0 = Don't backup Your Current Service Configuration before services are changes
                                #1 = Backup Your Current Service Configuration before services are changes
# Will be script's directory named "(ComputerName)-Service-Backup.csv"

$Script:DryRun = 0              #0 = Runs script normally, 1 = Runs script but shows what will be changed

$Script:ScriptLog = 0           #0 = Don't make a log file, 1 = Make a log file
# Will be script's directory named `Script.log` (default)

$Script:LogName = "Script.log"  #Name of log file (you can change it)

$Script:LogBeforeAfter = 0      #0 = Don't make a file of all the services before and after the script
                                #1 = Make a file of all the services before and after the script
# Will be script's directory named `Services-Before.log` and `Services-After.log`

$Script:ScriptVerCheck = 0      #0 = Skip Check for update of Script File, 1 = Check for update of Script File
# Note: If found will Auto download and runs that, File name will be "BlackViper-Win10-Ver.(version#).ps1"

$Script:BatUpdateScriptFileName = 1 #0-Don't ->, 1-Update Bat file with new script filename (if update is found)

$Script:ServiceVerCheck = 0     #0 = Skip Check for update of Service File, 1 = Check for update of Service File
# Note: If found will Auto download will be used

$Script:ShowAlreadySet = 1      #0 = Don't Show Already set Services, 1 = Show Already set Services

$Script:ShowNonInstalled = 0    #0 = Don't Show Services not present, 1 = Show Services not present

$Script:InternetCheck = 0       #0 = Checks if you have internet, 1 = Bypass check if your pings are blocked
# Use if Pings are Blocked or can't ping GitHub.com

$Script:EditionCheck = 0        #0 = Check if Home or Pro Edition
                                #"Pro" = Set Edition as Pro (Needs "s)
                                #"Home" = Set Edition as Home (Needs "s)

$Script:BuildCheck = 0          #0 = Check Build (Creator's Update Minimum), 1 = Skips this check

$Script:XboxService = 0         #0 = Change Xbox Services, 1 = Skip Change Xbox Services
#--------------------------------
# Best not to use these unless asked to (these stop automated)
$Script:Diagnostic = 0          #0 = Doesn't show Shows diagnostic information
                                #1 = Shows diagnostic information

$Script:DevLog = 0              #0 = Doesn't make a Dev Log, 1 = Makes a log files
# Devlog contains - services change, before and after for services, and diagnostic info 
#--------------------------------------------------------------------------
# Starts the script (Do not change)
ArgsAndVarSet
