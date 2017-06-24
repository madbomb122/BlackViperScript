$Global:filebase = $PSScriptRoot + "\"

Function OpenWebsite ([String]$Url) { [System.Diagnostics.Process]::Start($Url) }

# XNL Input
$inputXML = @'
<Window
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Black Viper Service Configuration Script By: MadBomb122" Height="318" Width="463" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" HorizontalAlignment="Center" VerticalAlignment="Center" ResizeMode="NoResize" BorderBrush="Black" Background="White">
    <Window.Effect>
        <DropShadowEffect/>
    </Window.Effect>
    <Grid>
        <CheckBox x:Name="DryrunCB" Content="Dryrun -Shows what will be changed" HorizontalAlignment="Left" Margin="9,222,0,0" VerticalAlignment="Top" Height="15" Width="213"/>
        <CheckBox x:Name="BeforeAndAfterCB" Content="Services Before and After" HorizontalAlignment="Left" Margin="202,160,0,0" VerticalAlignment="Top" Height="15" Width="157"/>
        <CheckBox x:Name="AlreadySetCB" Content="Show Already Set Services" HorizontalAlignment="Left" Margin="9,160,0,0" VerticalAlignment="Top" Height="15" Width="158" IsChecked="True"/>
        <CheckBox x:Name="NotInstalledCB" Content="Show Not Installed Services" HorizontalAlignment="Left" Margin="9,175,0,0" VerticalAlignment="Top" Height="15" Width="166"/>
        <Label Content="Display Options" HorizontalAlignment="Left" Margin="4,137,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
        <Label Content="Log Options" HorizontalAlignment="Left" Margin="197,138,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
        <CheckBox x:Name="ScriptLogCB" Content="Script Log:" HorizontalAlignment="Left" Margin="202,175,0,0" VerticalAlignment="Top" Height="15" Width="75"/>
        <Label Content="Misc Options" HorizontalAlignment="Left" Margin="4,199,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
        <Button x:Name="RunScriptButton" Content="Run Script" HorizontalAlignment="Left" Margin="258,213,0,0" VerticalAlignment="Top" Width="168" Height="35" FontWeight="Bold"/>
        <CheckBox x:Name="BackupServiceCB" Content="Backup Current Service Configuration" HorizontalAlignment="Left" Margin="9,237,0,0" VerticalAlignment="Top" Height="15" Width="218"/>
        <TabControl Height="137" Margin="0,-1,0,0" VerticalAlignment="Top">
            <TabItem x:Name="Black_Viper_Conf_Tab" Header="Black Viper Services" Margin="-2,0,2,0">
                <Grid Background="#FFE5E5E5">
                    <Label Content="Service Configurations:" HorizontalAlignment="Left" Margin="2,65,0,0" VerticalAlignment="Top" Height="27" Width="146" FontWeight="Bold"/>
                    <ComboBox x:Name="ServiceConfig" HorizontalAlignment="Left" Margin="139,68,0,0" VerticalAlignment="Top" Width="98" Height="23">
                        <ComboBoxItem Content="Default" HorizontalAlignment="Left" Width="96" IsSelected="True"/>
                        <ComboBoxItem Content="Safe" HorizontalAlignment="Left" Width="96"/>
                    </ComboBox>
                    <RadioButton x:Name="RadioAll" Content="All -Change All Services" HorizontalAlignment="Left" Margin="5,26,0,0" VerticalAlignment="Top" IsChecked="True"/>
                    <RadioButton x:Name="RadioMin" Content="Min -Change Services that are Differant from Default to Safe/Tweaked" HorizontalAlignment="Left" Margin="5,41,0,0" VerticalAlignment="Top"/>
                    <Label Content="Black Viper Configuration Options (BV Services Only)" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="2,3,0,0" FontWeight="Bold"/>
                    <Label x:Name="CustomNote" Content="*Note: Configure in next tab" HorizontalAlignment="Left" Margin="240,65,0,0" VerticalAlignment="Top" Width="170" Height="27" FontWeight="Bold"/>
                </Grid>
            </TabItem>
            <TabItem x:Name="Custom_Conf_Tab" Header="Custom Services" Margin="-2,0,2,0">
                <Grid Background="#FFE5E5E5">
                    <Button x:Name="btnOpenFile" Content="Browse File" HorizontalAlignment="Left" Margin="9,17,0,0" VerticalAlignment="Top" Width="66" Height="22"/>
                    <TextBox x:Name="LoadFileTxtBox" HorizontalAlignment="Left" Height="23" Margin="9,68,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="411"/>
                    <Label Content="Config File:" HorizontalAlignment="Left" Margin="4,45,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
                    <Label Content="Type in Path/File or Browse for file" HorizontalAlignment="Left" Margin="100,45,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
                </Grid>
            </TabItem>
            <TabItem x:Name="Various_Checks_Tab" Header="Various Check" Margin="-2,0,2,0">
                <Grid Background="#FFE5E5E5">
                    <CheckBox x:Name="ScriptUpdateCB" Content="Script Update*" HorizontalAlignment="Left" Margin="9,42,0,0" VerticalAlignment="Top" Height="15" Width="99"/>
                    <CheckBox x:Name="ServiceUpdateCB" Content="Service Update" HorizontalAlignment="Left" Margin="9,27,0,0" VerticalAlignment="Top" Height="15" Width="99"/>
                    <CheckBox x:Name="InternetCheckCB" Content="Skip Internet Check" HorizontalAlignment="Left" Margin="9,57,0,0" VerticalAlignment="Top" Height="15" Width="124"/>
                    <Label Content="Update Items" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="4,4,0,0" FontWeight="Bold"/>
                    <CheckBox x:Name="BuildCheckCB" Content="Skip Build Check" HorizontalAlignment="Left" Margin="203,27,0,0" VerticalAlignment="Top" Height="15" Width="111"/>
                    <CheckBox x:Name="EditionCheckCB" Content="Skip Edition Check Set as :" HorizontalAlignment="Left" Margin="203,42,0,0" VerticalAlignment="Top" Height="15" Width="161"/>
                    <ComboBox x:Name="EditionConfig" HorizontalAlignment="Left" Margin="363,39,0,0" VerticalAlignment="Top" Width="61" Height="23">
                        <ComboBoxItem Content="Home" HorizontalAlignment="Left" Width="59" IsSelected="True"/>
                        <ComboBoxItem Content="Pro" HorizontalAlignment="Left" Width="59"/>
                    </ComboBox>
                    <Label Content="*Will run and use current settings" HorizontalAlignment="Left" Margin="3,66,0,0" VerticalAlignment="Top" FontWeight="Bold"/>
                    <Label Content="Misc Checks" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="198,4,0,0" FontWeight="Bold"/>

                </Grid>
            </TabItem>
            <TabItem x:Name="Dev_Option_Tab" Header="Dev Option" Margin="-2,0,2,0">
                <Grid Background="#FFE5E5E5">
                    <CheckBox x:Name="DiagnosticCB" Content="Diagnostic Output (On Error)" HorizontalAlignment="Left" Margin="9,11,0,0" VerticalAlignment="Top" Height="15" Width="174"/>
                    <CheckBox x:Name="DevLogCB" Content="Dev Log" HorizontalAlignment="Left" Margin="9,26,0,0" VerticalAlignment="Top" Height="15" Width="174"/>
                </Grid>
            </TabItem>
        </TabControl>
        <TextBox x:Name="LogNameInput" HorizontalAlignment="Left" Height="19" Margin="279,174,0,0" TextWrapping="Wrap" Text="Script.log" VerticalAlignment="Top" Width="147"/>
        <Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,136,0,0" Stroke="Black" VerticalAlignment="Top"/>
        <Rectangle Fill="#FFFFFFFF" Height="1" Margin="0,258,0,0" Stroke="Black" VerticalAlignment="Top"/>
        <Button x:Name="CopyrightButton" Content="Copyright" HorizontalAlignment="Left" Margin="0,259,0,0" VerticalAlignment="Top" Width="149" FontStyle="Italic" AutomationProperties.HelpText="Show Copyright"/>
        <Button x:Name="BlackViperWSButton" Content="BlackViper's Website" HorizontalAlignment="Left" Margin="149,259,0,0" VerticalAlignment="Top" Width="149" FontStyle="Italic"/>
        <Button x:Name="Madbomb122WSButton" Content="Madbomb122's Website" HorizontalAlignment="Left" Margin="298,259,0,0" VerticalAlignment="Top" Width="149" FontStyle="Italic"/>
        <Rectangle Fill="#FFFF9F9F" Margin="0,279,0,0" Stroke="Black" Height="10" VerticalAlignment="Top"/>
        <Rectangle Fill="#FFFF9F9F" Margin="447,0,0,0" Stroke="Black" HorizontalAlignment="Left" Width="10"/>
    </Grid>
</Window>
'@

$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML

$reader=(New-Object System.Xml.XmlNodeReader $xaml) 
$Form=[Windows.Markup.XamlReader]::Load( $reader )

# Store XML Objects In PowerShell
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}

#===========================================================================
# Actually make the objects work
#===========================================================================

$WPFbtnOpenFile.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $filebase
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
	$Script:ServiceConfigFile = $OpenFileDialog.filename
	$WPFLoadFileTxtBox.Text = $ServiceConfigFile
})

$WPFRunScriptButton.Add_Click({
    [void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
    $result = [Microsoft.VisualBasic.Interaction]::MsgBox("Run?", 'YesNoCancel,Question', "Respond please")

    switch ($result) {
        "Yes" { "Ah good" }
        "No" { "Sorry to hear that" }
        "Cancel" { "Bye…" }
    }
})

$CopyrightItems = 'Copyright (c) 1999-2017 Charles "Black Viper" Sparks - Services Configuration

The MIT License (MIT)

Copyright (c) 2017 Madbomb122 - Black Viper Service Script

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.'

$WPFCopyrightButton.Add_Click({
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [Windows.Forms.MessageBox]::Show($CopyrightItems,"Copyright", 'OK')
})

# Combo Box
#$WPFServiceConfig

$WPFLogNameInput.IsEnabled = $false
$WPFEditionConfig.IsEnabled = $false

If($IsLaptop -ne "-Lap") { [void]$WPFServiceConfig.Items.Add("Tweaked")	}
[void]$WPFServiceConfig.Items.Add("Custom Setting *")

$WPFScriptLogCB.Add_Checked({
    $Script:MakeLog = 1
    $WPFLogNameInput.IsEnabled = $true
})

$WPFScriptLogCB.Add_UnChecked({
    $Script:MakeLog = 0
    $WPFLogNameInput.IsEnabled = $false
})

$WPFEditionCheckCB.Add_Checked({
    $Script:Edition_Check = 1
    $WPFEditionConfig.IsEnabled = $true
})

$WPFEditionCheckCB.Add_UnChecked({
    $Script:Edition_Check = 0
    $WPFEditionConfig.IsEnabled = $false
})


# Checkbox
If($WPFDryrunCB.IsChecked){$Script:Dry_Run = 1 } Else { $Script:Dry_Run = 0 }
If($WPFBeforeAndAfterCB.IsChecked){ $Script:LogBeforeAfter = 1 } Else { $Script:LogBeforeAfter = 0 }
If($WPFAlreadySetCB.IsChecked){ $Script:Show_Already_Set = 1 } Else { $Script:Show_Already_Set = 0}
If($WPFNotInstalledCB.IsChecked){ $Script:Show_Non_Installed = 1 } Else { $Script:Show_Non_Installed = 0}
If($WPFBackupServiceCB.IsChecked){ $Script:BackupServiceConfig = 1 } Else { $Script:BackupServiceConfig = 0}
If($WPFScriptUpdateCB.IsChecked){ $Script:Script_Ver_Check = 1 } Else { $Script:Script_Ver_Check = 0}
If($WPFServiceUpdateCB.IsChecked){ $Script:Service_Ver_Check = 1 } Else { $Script:Service_Ver_Check = 0}
If($WPFInternetCheckCB.IsChecked){ $Script:Internet_Check = 1 } Else { $Script:Internet_Check = 0}
If($WPFBuildCheckCB.IsChecked){ $Script:Build_Check = 1 } Else { $Script:Build_Check = 0}
If($WPFDiagnosticCB.IsChecked){ $Script:Diagnostic = 1 } Else { $Script:Diagnostic = 0}
If($WPFDevLogCB.IsChecked){ $Script:DevLog = 1 } Else { $Script:DevLog = 0}

# Button
#$WPFRunScriptButton.Add_Click({ })

$WPFBlackViperWSButton.Add_Click({ OpenWebsite "http://www.blackviper.com/" })
$WPFMadbomb122WSButton.Add_Click({ OpenWebsite "https://github.com/madbomb122/" })

# Radio Button
If($WPFRadioAll.IsChecked -eq $true) {
    $Script:All_or_Min = "-full" 
} Else {
    $Script:All_or_Min = "-min" 
}

# TextBox
$Script:ServiceConfigFile = $WPFLoadFileTxtBox.Text
$Script:LogName = $WPFLogNameInput.Text

#Show Gui
Function Show-GUI{ $Form.ShowDialog() | out-null }

Show-GUI
