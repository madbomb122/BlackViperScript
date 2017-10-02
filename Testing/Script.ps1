Function Load-Gui {
[xml]$XAML = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  Title="Services List" Height="261.541" Width="423.299" ResizeMode="NoResize" BorderBrush="Black" Background="White">
    <Window.Effect>
        <DropShadowEffect/>
    </Window.Effect>
    <Grid>
        <DataGrid Name="dataGrid" AutoGenerateColumns="False" AlternationCount="1" SelectionMode="Single" IsReadOnly="True" HeadersVisibility="Column" Margin="10,32,10,10" AlternatingRowBackground="#FFD8D8D8" CanUserResizeRows="False" >
            <DataGrid.Columns>
                <DataGridTemplateColumn>
                    <DataGridTemplateColumn.CellTemplate>
                        <DataTemplate>
                            <CheckBox x:Name="CB" Width="25" IsChecked="{Binding IsChecked, ElementName=headerCheckBox}"/>
                        </DataTemplate>
                    </DataGridTemplateColumn.CellTemplate>
                </DataGridTemplateColumn>
                <DataGridTextColumn Header="Common Name" Width="125" Binding="{Binding CName}"/>
                <DataGridTextColumn Header="Service Name" Width="125" Binding="{Binding SName}"/>
                <DataGridTextColumn Header="Current Status" Width="125"  Binding="{Binding Status}"/>
            </DataGrid.Columns>
        </DataGrid>
        <Button Name="GenerateButton" Content="Generate" HorizontalAlignment="Left" Margin="10,7,0,0" VerticalAlignment="Top" Width="75"/>
    </Grid>
</Window>
"@

	[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
	$reader = (New-Object System.Xml.XmlNodeReader $xaml)
	$Form = [Windows.Markup.XamlReader]::Load( $reader )
	$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name) -Scope Script}

	$CurrServices = Get-Service | Select DisplayName, Name, StartType
	[System.Collections.ArrayList]$CBNameList = @()

	$WPF_GenerateButton.Add_Click({ Generate-Services })

	$Form.ShowDialog() | Out-Null
}

Function Generate-Services {
	[System.Collections.ArrayList]$DataGridList = @()

	ForEach($item In $CurrServices) {
		$ServiceName = $item.Name
		$ServiceCommName = $item.DisplayName
		$ServiceType = $item.StartType
		If($CurrServices.Name -Contains $ServiceName) {
			$DispTemp = "$ServiceCommName - $ServiceType"
			$CBName = "WPF_"+$ServiceName + "_1CB"

			If(!($CBNameList -Contains $CBName)) {
				New-Variable -Name $CBName -Value ([System.Windows.Controls.CheckBox]::new()) -Scope Script
				$checkbox = Get-Variable -Name $CBName -ValueOnly
				$CBNameList.Add($CBName)
			} Else{ $checkbox = Get-Variable -Name $CBName -ValueOnly }
			
			If($ServiceType -eq "Disabled"){ $checkbox.IsChecked = $True }

			$Object = New-Object PSObject -Property @{ CB = $checkbox ;CName=$ServiceCommName ;SName = $ServiceName ;Status = $ServiceType }
			$DataGridList += $Object
		}
	}
	$WPF_dataGrid.ItemsSource = $DataGridList
    $WPF_dataGrid.items.Refresh()
}

Load-Gui