$inputXML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Test" Height="343" Width="487.117" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" HorizontalAlignment="Center" VerticalAlignment="Center" ResizeMode="NoResize" BorderBrush="Black" Background="White" WindowStyle="ThreeDBorderWindow">
    <Grid>
        <TabControl x:Name="TabControl" Height="233" Margin="0,-1,0,0" VerticalAlignment="Top">
            <TabItem x:Name="ServicesCB_Tab" Header="Services" Margin="-2,0,2,0"> <Grid Background="#FFE5E5E5">
                <ScrollViewer VerticalScrollBarVisibility="Visible" Margin="0,38,0,0"> <StackPanel x:Name="StackCBHere" Width="458" ScrollViewer.VerticalScrollBarVisibility="Auto" CanVerticallyScroll="True"/> </ScrollViewer>
                <CheckBox x:Name="CustomCB" Content="Check Checker" HorizontalAlignment="Left" Margin="287,3,0,0" VerticalAlignment="Top" Width="158"/>
                <Button x:Name="LoadServicesButton" Content="Load Services" HorizontalAlignment="Left" Margin="3,1,0,0" VerticalAlignment="Top" Width="76"/>
                <Label x:Name="ServiceNote" Content="Uncheck what you &quot;Don't want to be changed&quot;" HorizontalAlignment="Left" Margin="196,15,0,0" VerticalAlignment="Top"/>
                <Label x:Name="ServiceLegendLabel" Content="Service -&gt; Current -&gt; Changed To" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="-2,15,0,0"/>
                <Label x:Name="ServiceClickLabel" Content="&lt;-- Click to load Service List" HorizontalAlignment="Left" Margin="75,-3,0,0" VerticalAlignment="Top"/> </Grid>
            </TabItem>
        </TabControl>
        <TextBox x:Name="Display" HorizontalAlignment="Left" Height="82" Margin="0,232,0,0" TextWrapping="Wrap" Text="Nothing" VerticalAlignment="Top" Width="481"/>
    </Grid>
</Window>
"@

    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$XAML = $inputXML -replace "x:N",'N'
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
    $xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name)} 

    $WPF_LoadServicesButton.Add_Click({ Generate-ServicesCB })
    $WPF_CustomCB.Add_Checked({ $WPF_Display.text = "WPF_CustomCB IS Checked" })
    $WPF_CustomCB.Add_UnChecked({ $WPF_Display.text = "WPF_CustomCB NOT Checked" })
			
Function Generate-ServicesCB {
    $WPF_LoadServicesButton.Visibility = 'Hidden'
    $WPF_ServiceClickLabel.Visibility = 'Hidden'

    [System.Collections.ArrayList]$Script:ServiceCBList = @()
    $Script:CurrServices = Get-Service | Select DisplayName, Name, StartType
    $ServiceCheckBoxCounter = 0

    ForEach($item In $CurrServices) {
        If($ServiceCheckBoxCounter -eq 4) { Break } #to stop loading soo many services for testing
        $ServiceType = $item.StartType
        $ServiceName = $item.Name
        $ServiceCommName = $item.DisplayName

            $DispTemp = "$ServiceCommName - $ServiceType"
            $CBName = "WPF_" + $ServiceName + "CB"
            $ServiceCheckBox = [System.Windows.Controls.CheckBox]::new()
            $ServiceCheckBox.Name = $CBName            
            $ServiceCheckBox.width = 450
            $ServiceCheckBox.height = 20
            $ServiceCheckBox.Content = "$DispTemp"
            $ServiceCheckBox.Add_Checked({ GetCustomBV })
            $ServiceCheckBox.Add_UnChecked({ GetCustomBV })
            $ServiceCheckBox.IsChecked = $true
            $WPF_StackCBHere.AddChild($ServiceCheckBox)

            $Object = New-Object -TypeName PSObject
            Add-Member -InputObject $Object -memberType NoteProperty -name "CBName" -value $CBName
            Add-Member -InputObject $Object -memberType NoteProperty -name "ServiceName" -value $ServiceName
            Add-Member -InputObject $Object -memberType NoteProperty -name "StartType" -value $ServiceTypeNum
            $Script:ServiceCBList += $Object
            $ServiceCheckBoxCounter++
    }
    $WPF_Display.text = "Done"
    $Script:GenLoad = $true
}

Function GetCustomBV {
    If($GenLoad -eq $true){
        $Temp = ""
        ForEach($item In $ServiceCBList) {
            $Temp += "$($item.CBName) ="
            If($($item.CBName).IsChecked -eq $false) {
                $Temp += " NOT checked`n"
            } ElseIf($($item.CBName).IsChecked -eq $true) {
                $Temp += " IS checked`n"
            } Else {
                $Temp += " Unknown`n"
            }
        }
    }
    $WPF_Display.text = $Temp
}

$Form.ShowDialog()| Out-Null
