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
$Script_Version = "0.0"
$Minor_Version = "0"
$Script_Date = "Apr-20-2018"
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
  System: Windows 10 x64 (64-bit)
  Edition: Home or Pro     (Can run on other Edition AT YOUR OWN RISK)
  Build: Creator's Update  (Can run on other Build AT YOUR OWN RISK)
  Files: This script and 'BlackViper.csv' (Service Configurations)

.DESCRIPTION
 Script that can set services based on Black Viper's Service Configurations.

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

Function GetServiceEnd {
	$ServiceEndL = @()
	$Tmp1 = ""
	$ServiceEnd1 = (Get-Service "*_*" | Select-Object Name )
	ForEach($End in $ServiceEnd1) { $ServiceEndL += $End.Name.Split('_')[1] }
	ForEach($End in $ServiceEndL) {
		If($Tmp1 -eq $End) { Return $Tmp1 } Else { $Tmp1 = $End }
	}
}
$Script:ServiceEnd = GetServiceEnd

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
'Automatic')#4 -Automatic (Delayed)

$ServicesTypeLst = @(
'Skip',     #0 -Skip Not Installed
'Disabled', #1 -Disable
'Manual',   #2 -Manual
'Automatic',#3 -Automatic
'Automatic (Delayed)')#4 -Automatic (Delayed)

$XboxServiceArr = @("XblAuthManager", "XblGameSave", "XboxNetApiSvc")
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

Function OpenWebsite([String]$Url) { [System.Diagnostics.Process]::Start($Url) }
Function LaptopCheck { $Script:PCType = (Get-CimInstance -Class Win32_ComputerSystem).PCSystemType ;If($PCType -ne 2) { Return "-Desk" } Return "-Lap" }

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

Function TOS { GuiStart }

##########
# Multi Use Functions -End
##########
# GUI -Start
##########

Function Update-Window {
	[cmdletBinding()]
	Param($Control,$Property,$Value,[Switch]$AppendContent)
	If($Property -eq "Close"){ $syncHash.Window.Dispatcher.invoke([action]{$syncHash.Window.Close()},"Normal") ;Return }
	$form.Dispatcher.Invoke([Action]{ If($PSBoundParameters['AppendContent']){ $Control.AppendText($Value) } Else{ $Control.$Property = $Value } }, "Normal")
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
	$Script:GuiLoad = 1
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
  Title="Black Viper Service Configuration Script By: MadBomb122" Height="355.061" Width="649.877" BorderBrush="Black" Background="White">
    <Window.Effect>
        <DropShadowEffect/>
    </Window.Effect>
    <Grid>
        <Label Content="Service Version:" HorizontalAlignment="Left" Margin="256,0,0,-1" VerticalAlignment="Bottom" Height="25"/>
        <Label Content="Script Version:" HorizontalAlignment="Left" Margin="1,0,0,-1" VerticalAlignment="Bottom" Height="25"/>
        <Button Name="RunScriptButton" Content="Run Script" Margin="0,0,0,21" VerticalAlignment="Bottom" Height="20" FontWeight="Bold"/>
        <TextBox Name="Script_Ver_Txt" HorizontalAlignment="Left" Height="20" Margin="82,0,0,0" TextWrapping="Wrap" Text="2.8.0 (6-21-2017)" VerticalAlignment="Bottom" Width="125" IsEnabled="False"/>
        <TextBox Name="Service_Ver_Txt" HorizontalAlignment="Left" Height="20" Margin="345,0,0,0" TextWrapping="Wrap" Text="2.0 (5-21-2017)" VerticalAlignment="Bottom" Width="129" IsEnabled="False"/>
        <TextBox Name="Release_Type_Txt" HorizontalAlignment="Left" Height="20" Margin="207,0,0,0" TextWrapping="Wrap" Text="Testing" VerticalAlignment="Bottom" Width="48" IsEnabled="False"/>
        <TabControl Name="TabControl" Margin="0,17,0,42">
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
                    <DataGrid Name="dataGrid" AutoGenerateColumns="False" AlternationCount="1" HeadersVisibility="Column" Margin="-2,38,0,-2" AlternatingRowBackground="#FFD8D8D8" CanUserResizeRows="False" IsTabStop="True" IsTextSearchEnabled="True" SelectionMode="Extended">
                        <DataGrid.Columns>
                            <DataGridTemplateColumn>
                                <DataGridTemplateColumn.Header>
                                    <CheckBox Name="ACUcheckboxChecked" IsEnabled="False"/>
                                </DataGridTemplateColumn.Header>
                                <DataGridTemplateColumn.CellTemplate>
                                    <DataTemplate>
                                        <CheckBox Name="GDCheckB" IsChecked="{Binding checkboxChecked,Mode=TwoWay,UpdateSourceTrigger=PropertyChanged}" IsEnabled="{Binding ElementName=CustomBVCB, Path=IsChecked}"/>
                                    </DataTemplate>
                                </DataGridTemplateColumn.CellTemplate>
                            </DataGridTemplateColumn>
                            <DataGridTextColumn Header="Common Name" Width="121" Binding="{Binding CName}"/>
                            <DataGridTextColumn Header="Service Name" Width="120" Binding="{Binding ServiceName}"/>
                            <DataGridTextColumn Header="Current Setting" Width="95" Binding="{Binding CurrType}"/>
                            <DataGridTemplateColumn Header="Black Viper" Width="95" CanUserSort="False">
                                <DataGridTemplateColumn.CellTemplate>
                                    <DataTemplate>
                                        <ComboBox ItemsSource="{Binding ServiceTypeListDG}" Text="{Binding Path=BVType, Mode=TwoWay, UpdateSourceTrigger=PropertyChanged}" IsEnabled="{Binding ElementName=CustomBVCB, Path=IsChecked}"/>
                                    </DataTemplate>
                                </DataGridTemplateColumn.CellTemplate>
                            </DataGridTemplateColumn>
                            <DataGridTextColumn Header="Description" Width="95" Binding="{Binding SrvDesc}"/>
                            <DataGridTextColumn Header="Path" Width="95" Binding="{Binding SrvPath}"/>
                        </DataGrid.Columns>
                    </DataGrid>
                    <Rectangle Fill="#FFFFFFFF" Height="1" Margin="-2,37,2,0" Stroke="Black" VerticalAlignment="Top"/>
                    <Label Name="ServiceClickLabel" Content="&lt;-- Click to load Service List" HorizontalAlignment="Left" Margin="75,-3,0,0" VerticalAlignment="Top"/>
                    <Button Name="LoadServicesButton" Content="Load Services" HorizontalAlignment="Left" Margin="3,1,0,0" VerticalAlignment="Top" Width="76"/>
                    <Button Name="SaveCustomSrvButton" Content="Save Current" HorizontalAlignment="Left" Margin="103,1,0,0" VerticalAlignment="Top" Width="80" Visibility="Hidden"/>
                    <Button Name="SaveRegButton" Content="Save Registry" HorizontalAlignment="Left" Margin="198,1,0,0" VerticalAlignment="Top" Width="80" Visibility="Hidden"/>
                    <Label Name="ServiceNote" Content="Uncheck what you &quot;Don't want to be changed&quot;" HorizontalAlignment="Left" Margin="196,15,0,0" VerticalAlignment="Top" Visibility="Hidden"/>
                    <CheckBox Name="CustomBVCB" Content="Customize Service" HorizontalAlignment="Left" Margin="288,3,0,0" VerticalAlignment="Top" Width="158" RenderTransformOrigin="0.696,0.4" Visibility="Hidden"/>
                </Grid>
            </TabItem>
        </TabControl>
        <Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,0,0,41" Stroke="Black" VerticalAlignment="Bottom"/>
        <Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,0,0,20" Stroke="Black" VerticalAlignment="Bottom"/>
        <Rectangle Fill="#FFFFFFFF" HorizontalAlignment="Left" Margin="255,0,0,0" Stroke="Black" Width="1" Height="20" VerticalAlignment="Bottom"/>
        <Menu Height="17" VerticalAlignment="Top">
            <MenuItem Header="_File" Height="17" Width="27">
                <MenuItem Name="Open" Header="Open File" Height="17" Margin="0"/>
                <MenuItem Name="Save" Header="Save File" Height="17"/>
                <Separator Height="2"/>
                <MenuItem Name="Exit_B" Header="_Exit" Height="17"/>
            </MenuItem>
            <MenuItem Header="Options" Height="17" Width="50">
                <MenuItem Header="Service Options" Height="17">
                    <MenuItem Name="XboxService_CB" Header="Skip Xbox Services" Height="17" IsCheckable="True"/>
                    <MenuItem Name="Dryrun_CB" Header="Dryrun -Show what will be changed (when ran)" Height="17" IsCheckable="True"/>
                </MenuItem>
                <MenuItem Header="Update Options" Height="17">
                    <MenuItem Name="ServiceUpdateCB" Header="Check for Service Update" Height="17" IsCheckable="True"/>
                    <MenuItem Name="ScriptVerCheck_CB" Header="Check for Script" Height="17" IsCheckable="True"/>
                    <MenuItem Name="InternetCheck_CB" Header="Skip Internet Check" Height="17" IsCheckable="True"/>
                    <MenuItem Name="BatUpdateScriptFileName_CB" Header="Update Script name in bat" Height="17" IsCheckable="True"/>
                </MenuItem>
                <MenuItem Header="Display Options" Height="17">
                    <MenuItem Name="ShowAlreadySet_CB" Header="Show Already Set Services" Height="17" IsCheckable="True"/>
                    <MenuItem Name="ShowNonInstalled_CB" Header="Show Not Installed Services" Height="17" IsCheckable="True"/>
                </MenuItem>
                <MenuItem Header="Log Options" Height="17">
                    <MenuItem Name="LogBeforeAfter_CB" Header="Log Services Before and After" Height="17" IsCheckable="True"/>
                    <MenuItem Name="ScriptLog_CB" Header="Save a Script Log" Height="17" IsCheckable="True"/>
                </MenuItem>
                <MenuItem Header="Backup Current Services" Height="17">
                    <MenuItem Name="BackupServiceTypeCsv" Header="Csv File" Height="17"  IsCheckable="True"/>
                    <MenuItem Name="BackupServiceTypeReg" Header="Reg File" Height="17"  IsCheckable="True"/>
                    <MenuItem Name="BackupServiceTypeBoth" Header="Csv + Reg File" Height="17"  IsCheckable="True"/>
                </MenuItem>
                <Separator Height="2"/>
                <MenuItem Header="SKIP CHECK AT YOUR OWN RISK!" Height="17" FontWeight="Bold" IsEnabled="False"/>
                <MenuItem Name="BuildCheck_CB" Header="Skip Build Check" Height="17" IsCheckable="True"/>
                <MenuItem Header="Skip Edition Check" Height="17">
                    <MenuItem Name="EditionConfigHome" Header="Home" Height="17" IsCheckable="True"/>
                    <MenuItem Name="EditionConfigPro" Header="Pro" Height="17" IsCheckable="True"/>
                </MenuItem>
                <Separator Height="2"/>
                <MenuItem Header="Dev Options" Height="17">
                    <MenuItem Name="DevLog_CB" Header="Dev Log" Height="17" IsCheckable="True"/>
                    <MenuItem Name="Diagnostic_CB" Header="Diagnostic Output (on Error)" Height="17" IsCheckable="True"/>
                </MenuItem>
            </MenuItem>
            <MenuItem Name="ContactButton" Header="Contact Me" Height="17" Width="70"/>
            <MenuItem Name="AboutButton" Header="About" Height="17" Width="43"/>
            <MenuItem Name="DonateButton" Header="Donate to Me" Height="17" Width="88" Background="#FFFFAD2F" FontWeight="Bold"/>
            <MenuItem Name="CopyrightButton" Header="Copyright" Height="17" Width="67" Background="#FF8ABEF0" FontWeight="Bold"/>
            <MenuItem Name="BlackViperWSButton" Header="BlackViper's Website" Height="17" Width="128" Background="#FFA7D24D" FontWeight="Bold"/>
            <MenuItem Name="Madbomb122WSButton" Header="Madbomb122's GitHub" Height="17" Width="140" Background="#FFFFE677" FontWeight="Bold"/>
        </Menu>
    </Grid>
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
	$WPF_CustomBVCB.Add_Checked({ CustomBVCBFun $True })
	$WPF_CustomBVCB.Add_UnChecked({ CustomBVCBFun $False })
	$WPF_btnOpenFile.Add_Click({ OpenSaveDiaglog 0 })
	$WPF_SaveCustomSrvButton.Add_Click({ OpenSaveDiaglog 1 })
	$WPF_SaveRegButton.Add_Click({ OpenSaveDiaglog 2 })
	$WPF_BlackViperWSButton.Add_Click({ OpenWebsite "http://www.blackviper.com/" })
	$WPF_Madbomb122WSButton.Add_Click({ OpenWebsite "https://github.com/madbomb122/" })
	$WPF_DonateButton.Add_Click({ OpenWebsite "https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/" })
	$WPF_LoadServicesButton.Add_Click({ GenerateServices })
	$WPF_CopyrightButton.Add_Click({ [Windows.Forms.MessageBox]::Show($CopyrightItems,"Copyright", 'OK') })
	$WPF_ACUcheckboxChecked.Add_Checked({ DGUCheckAll $True })
	$WPF_ACUcheckboxChecked.Add_UnChecked({ DGUCheckAll $False })

	$CopyrightItems = 'Copyright (c) 1999-2017 Charles "Black Viper" Sparks - Services Configuration

--------------------------------------------------------------------------------

The MIT License (MIT) + an added Condition

Copyright (c) 2017 Madbomb122 - Black Viper Service Configuration Script

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice(s), this permission notice and ANY original donation link shall be included in all copies or substantial portions of the Software.

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
	"WinDefend",
	"xbgm")
	For($i=0;$i -ne 5;$i++){ $Skip_Services[$i] = $Skip_Services[$i] + $ServiceEnd }

	$Script:CurrServices = Get-Service | Select-Object DisplayName, Name, StartType
	$Script:RunScript = 0
	If($All_or_Min -eq "-full"){ $WPF_RadioAll.IsChecked = $True } Else{ $WPF_RadioMin.IsChecked = $True }
	If($IsLaptop -eq "-Lap"){ $WPF_ServiceConfig.Items.RemoveAt(2) }
	$Script:BVCount = $WPF_ServiceConfig.Items.Count

	$WPF_LoadFileTxtBox.Text = $ServiceConfigFile
	$WPF_Script_Ver_Txt.Text = "$Script_Version.$Minor_Version ($Script_Date)"
	$WPF_Service_Ver_Txt.Text = "$ServiceVersion ($ServiceDate)"
	$WPF_Release_Type_Txt.Text = $Release_Type
	$Script:ServiceImport = 1
	HideCustomSrvStuff
	RunDisableCheck
	Clear-Host
	DisplayOutMenu "Displaying GUI Now" 14 0 1 0
	DisplayOut "`nTo exit you can close the GUI or Powershell Window." 14 0
	$Form.ShowDialog() | Out-Null
}

Function CustomBVCBFun([Bool]$Choice) {
	$WPF_ACUcheckboxChecked.IsEnabled = $Choice
	If($Choice){
		$WPF_SaveCustomSrvButton.content = "Save Selection"
		$WPF_dataGrid.ItemsSource = $DataGridListCust
	} Else {
		$WPF_SaveCustomSrvButton.content = "Save Current"
		$WPF_dataGrid.ItemsSource = $DataGridListOrig

	}
	$WPF_dataGrid.Items.Refresh()	
	RunDisableCheck
}

Function RunDisableCheck {
	$WPF_RunScriptButton.IsEnabled = $False
	$WPF_RunScriptButton.content = "Disabled... This is for Display ONLY"
}

Function GenerateServices {
#   StartMode = StartType
#	Get-CimInstance Win32_service | Select-Object DisplayName, Name, StartMode, Description, PathName

	If($SrvCollected -ne 0) { $Script:ServiceInfo = Get-CimInstance Win32_service | Select-Object Name, Description, PathName ;$Script:SrvCollected = 1 }
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
	[System.Collections.ArrayList]$Script:DataGridListOrig = @{}
	[System.Collections.ArrayList]$Script:DataGridListCust = @{}

	ForEach($item In $ServCB) {
		$ServiceName = $($item.ServiceName)
		If($ServiceName -Like "*_*"){ $ServiceName = $ServiceName.Split('_')[0] + "_$ServiceEnd" }
		If($CurrServices.Name -Contains $ServiceName) {
			$tmp = $ServiceInfo -match $ServiceName
			$SrvDescription = $tmp.Description
			$SrvPath = $tmp.PathName
			$ServiceTypeNum = $($item.$BVService)
			$ServiceCurrType = ($CurrServices.Where{$_.Name -eq $ServiceName}).StartType
			Switch($ServiceCurrType) {
				"Disabled" { $ServiceCurrType = "Disabled" ;Break }
				"Manual" { $ServiceCurrType = "Manual" ;Break }
				"Automatic" { $exists = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName\").DelayedAutostart ;If($exists -eq 1){ $ServiceCurrType = "Automatic (Delayed)" } Else{ $ServiceCurrType = "Automatic" } ;Break }
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
			If($ServiceTypeNum -eq 4){ $ServiceType += " (Delayed)" }
			If($ServiceName -Is [system.array]){ $ServiceName = $ServiceName[0] }
			$ServiceCommName = ($CurrServices.Where{$_.Name -eq $ServiceName}).DisplayName
			$Script:DataGridListOrig += New-Object PSObject -Property @{ checkboxChecked = $checkbox ;CName=$ServiceCommName ;ServiceName = $ServiceName ;CurrType = $ServiceCurrType ;BVType = $ServiceType ;StartType = $ServiceTypeNum; ServiceTypeListDG = $ServicesTypeLst; SrvDesc = $SrvDescription; SrvPath = $SrvPath }
			$Script:DataGridListCust += New-Object PSObject -Property @{ checkboxChecked = $checkbox ;CName=$ServiceCommName ;ServiceName = $ServiceName ;CurrType = $ServiceCurrType ;BVType = $ServiceType ;StartType = $ServiceTypeNum; ServiceTypeListDG = $ServicesTypeLst; SrvDesc = $SrvDescription; SrvPath = $SrvPath }
		}
	}
	$WPF_dataGrid.ItemsSource = $DataGridListOrig
	$WPF_dataGrid.Items.Refresh()

	If(!($ServicesGenerated)) {
		$WPF_ServiceClickLabel.Visibility = 'Hidden'
		$WPF_ServiceNote.Visibility = 'Visible'
		$WPF_CustomBVCB.Visibility = 'Visible'
		$WPF_SaveCustomSrvButton.Visibility = 'Visible'
		$WPF_SaveRegButton.Visibility = 'Visible'
		$WPF_LoadServicesButton.content = "Reload"
		$Script:ServicesGenerated = $True
	}
}

Function DGUCheckAll([Bool]$Choice) {
	ForEach($item in $DataGridListCust){ $item.checkboxChecked = $Choice }
	$WPF_dataGrid.Items.Refresh()
}

Function GetCustomBV {
	$Script:LoadServiceConfig = 2
	[System.Collections.ArrayList]$Script:csvTemp = @()
	$ServiceCBList = $WPF_dataGrid.Items.Where({$_.checkboxChecked -eq $true})
	ForEach($item In $ServiceCBList) {
		$BVTypeS = BVTypeNameToNumb $item.BVType
		$Script:csvTemp += New-Object PSObject -Property @{ ServiceName = $item.ServiceName ;StartType = $BVTypeS } 
	}
	[System.Collections.ArrayList]$Script:csv = $Script:csvTemp
}

##########
# GUI -End
##########

Function GenerateSaveService {
	$TMPServiceL = @()
	ForEach($Service In $AllService) {
		$ServiceName = $Service.Name
		If(!($Skip_Services -Contains $ServiceName)) {
			Switch("$($Service.StartType)") {
				"Disabled" { $StartType = 1 ;Break }
				"Manual" { $StartType = 2 ;Break }
				"Automatic" { $exists = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\$ServiceName\").DelayedAutostart ;If($exists -eq 1){ $StartType = 4 } Else{ $StartType = 3 } ;Break }
				Default { $StartType = "$($Service.StartType)" ;Break }
			}
			If($ServiceName -Like "*_$ServiceEnd"){ $ServiceName = $ServiceName.Split('_')[0] + "_?????" }
			$TMPServiceL += New-Object PSObject -Property @{ ServiceName = $ServiceName ;StartType = $StartType }
		}
	}
	Return $TMPServiceL
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
	If($BackupServiceConfig -eq 1){
		If($BackupServiceType -eq 1){ Save_ServiceBackup }
		ElseIf($BackupServiceType -eq 0){ RegistryServiceFileBackup }
		ElseIf($BackupServiceType -eq 2){ Save_ServiceBackup ;RegistryServiceFileBackup }
	}
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
			LeftLineLog ;DisplayOutMenu "No Internet connection detected.                 " 2 0 0 1 ;RightLineLog
			LeftLineLog ;DisplayOutMenu "Tested by pinging GitHub.com                     " 2 0 0 1 ;RightLineLog
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

Function ArgsAndVarSet {
	$Script:IsLaptop = LaptopCheck
	If($PassedArg.Length -gt 0){ GetArgs }

	$Script:WinSku = (Get-CimInstance Win32_OperatingSystem).OperatingSystemSKU
	# 48 = Pro, 49 = Pro N
	# 98 = Home N, 100 = Home (Single Language), 101 = Home

	$Script:FullWinEdition = (Get-CimInstance Win32_OperatingSystem).Caption
	$Script:WinEdition = $FullWinEdition.Split(' ')[-1]
	# Pro or Home

	# https://en.wikipedia.org/wiki/Windows_10_version_history
	$Script:MinBuild = 15063
	$Script:BuildVer = [Environment]::OSVersion.Version.build
	# 17133 = Spring Creators Update	
	# 16299 = Fall Creators Update
	# 15063 = Creators Update
	# 14393 = Anniversary Update
	# 10586 = First Major Update
	# 10240 = First Release

	$Script:MinVer = 1703
	$Script:Win10Ver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).ReleaseId
	# 1803 = Spring Creators Update	
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
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## !!                                            !!
## !!            SAFE TO EDIT VALUES             !!
## !!                                            !!
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# Edit values (Option) to your preference

# Function = Option             #Choices
$Script:AcceptToS = 0           #0 = See ToS, Anything else = Accept ToS

$Script:Automated = 0           #0 = Pause on - User input, On Errors, or End of Script, 1 = Close on
# Automated = 1, Implies that you accept the "ToS"

$Script:BackupServiceConfig = 0 #0 = Don't backup Your Current Service Configuration before services are changes
                                #1 = Backup Your Current Service Configuration before services are changes (Configure type below)
$Script:BackupServiceType = 1
# 0 = ".reg" file that you can change w/o using script
# 1 = ".csv' file type that can be imported into script
# 2 = both the above types
# Will be in script's directory named "(ComputerName)-Service-Backup.(File Type)"

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

$Script:InternetCheck = 0       #0 = Checks if you have Internet, 1 = Bypass check if your pings are blocked
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
