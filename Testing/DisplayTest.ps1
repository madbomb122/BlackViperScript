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


[xml]$XAML = @"
    <Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Test" Height="355" Width="655" BorderBrush="Black" Background="White">
        <Grid>
         <DataGrid Name="dgtest" AutoGenerateColumns="False">
                <DataGrid.RowStyle>
                    <Style TargetType="{x:Type DataGridRow}">
                        <Style.Triggers> 
                            <DataTrigger Binding="{Binding Path=IsChecked, UpdateSourceTrigger=PropertyChanged}" Value="True">
                                <Setter Property="Background" Value="DarkBlue"/>
                                <Setter Property="Foreground" Value="White"/>
                            </DataTrigger>
                        </Style.Triggers>
                    </Style>
                </DataGrid.RowStyle>
                <DataGrid.Columns>
                    <DataGridCheckBoxColumn Header="Check" Binding="{Binding IsChecked, Mode=TwoWay, NotifyOnTargetUpdated=True, UpdateSourceTrigger=PropertyChanged}">
                    </DataGridCheckBoxColumn>
                    <DataGridTextColumn Header="Name" Binding="{Binding Name}"/>
                    <DataGridTextColumn Header="Count" Binding="{Binding Count}"/>
                </DataGrid.Columns>
            </DataGrid>
        </Grid>
    </Window>
"@

    [void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
    $Form = [Windows.Markup.XamlReader]::Load( (New-Object System.Xml.XmlNodeReader $xaml) )
    $xaml.SelectNodes("//*[@Name]") | ForEach-Object{Set-Variable -Name "WPF_$($_.Name)" -Value $Form.FindName($_.Name) -Scope Script }

    $Runspace = [runspacefactory]::CreateRunspace()
    $PowerShell = [PowerShell]::Create()
    $PowerShell.RunSpace = $Runspace
    $Runspace.Open()

    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $i=0
    [System.Collections.ArrayList]$Script:DataGridListOrig = @{}
    Foreach($itm in $colors){
        $Script:DataGridListOrig += New-Object PSObject -Property @{ IsChecked = $False ;Name=$itm ;Count = $i }
        $i++
    }
    $WPF_dgtest.ItemsSource = $DataGridListOrig
    $WPF_dgtest.Items.Refresh()

    $Form.ShowDialog() | Out-Null
