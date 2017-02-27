@ECHO OFF

:: Remove the 2 Colons infront of the command you want to run

:: First Line Description of Command
:: Second Line Command

::Run script with Menu Selection
::PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File %~dp0BlackViper-Win10.ps1' -Verb RunAs}"

::Run script with Black Viper Default
::PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File %~dp0BlackViper-Win10.ps1 -Set 1' -Verb RunAs}"

::Run script with Black Viper Safe
::PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File %~dp0BlackViper-Win10.ps1 -Set 2' -Verb RunAs}"

::Run script with Black Viper Tweaked
::PowerShell.exe -NoProfile -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File %~dp0BlackViper-Win10.ps1 -Set 3' -Verb RunAs}"
