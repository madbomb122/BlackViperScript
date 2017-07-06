$inputXML = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="Test" Height="343" Width="487.117" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" HorizontalAlignment="Center" VerticalAlignment="Center" ResizeMode="NoResize" BorderBrush="Black" Background="White" WindowStyle="ThreeDBorderWindow">
    <Grid>
        <TabControl x:Name="TabControl" Height="233" Margin="0,-1,0,0" VerticalAlignment="Top">
            <TabItem x:Name="ServicesCB_Tab" Header="Services" Margin="-2,0,2,0"> <Grid Background="#FFE5E5E5">
                <Button x:Name="LoadServicesButton" Content="Load Services" HorizontalAlignment="Left" Margin="10,28,0,0" VerticalAlignment="Top" Width="76"/>
                <ScrollBar HorizontalAlignment="Left" Margin="451,0,0,0" VerticalAlignment="Top" Height="205" Width="9"/>
                <Label x:Name="ServiceNote" Content="Uncheck what you &quot;Don't want to be changed&quot;" HorizontalAlignment="Left" Margin="196,2,0,0" VerticalAlignment="Top"/>
                <Label x:Name="ServiceLegendLabel" Content="Service -&gt; Current -&gt; Changed To" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="2,2,0,0"/>
                <Label x:Name="ServiceClickLabel" Content="&lt;-- Click to load Service List" HorizontalAlignment="Left" Margin="82,24,0,0" VerticalAlignment="Top"/> </Grid>
            </TabItem>
        </TabControl>
    </Grid>
</Window>
"@

    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    [xml]$XAML = $inputXML -replace "x:N",'N'
    $reader=(New-Object System.Xml.XmlNodeReader $xaml)
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
    $xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name)} 

    $WPF_LoadServicesButton.Add_Click({ Generate-ServicesCB })

Function Generate-ServicesCB {
    $WPF_LoadServicesButton.Visibility = 'Hidden'
    $WPF_ServiceClickLabel.Visibility = 'Hidden'

    [System.Collections.ArrayList]$Script:ServiceCBList = @()
    $Script:CurrServices = Get-Service | Select DisplayName, Name, StartType
    $ServiceCheckBoxCounter = 0

    ForEach($item In $CurrServices) {
        $ServiceType = $item.StartType
        $ServiceName = $item.Name
        $ServiceCommName = $item.DisplayName

            $ServiceCheckBoxCounter++
            $DispTemp = "$ServiceCommName ($ServiceName) - $ServiceType"

            $ServiceCheckBox = New-Object System.Windows.Forms.CheckBox        
            $ServiceCheckBox.UseVisualStyleBackColor = $True
            $ServiceCheckBox.Size = New-Object System.Drawing.Size(450,22)
            $ServiceCheckBox.TabIndex = 2
            $ServiceCheckBox.Text = "$DispTemp"
            $ServiceCheckBox.Location = New-Object System.Drawing.Size(10,((($ServiceCheckBoxCounter - 1) * 17) + 5))

            $CBName = $ServiceName + "CB"
            $ServiceCheckBox.Name = $CBName
            $ServiceCheckBox.Checked = $true

            #Error is "You cannot call a method on a null-valued expression." on line under here 
            $WPF_ServicesCB_Tab.Controls.Add($ServiceCheckBox)
    }
}

$Form.ShowDialog()| Out-Null
