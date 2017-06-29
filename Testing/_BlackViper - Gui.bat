@ECHO OFF

::----------------------------------------------------------------------
:: Do not change unless you know what you are doing
Set Script_File=BlackViper-Gui.ps1
Set Script_Directory=%~dp0
Set Script_Path=%Script_Directory%%Script_File%

:: DO NOT CHANGE ANYTHING PAST THIS LINE
::----------------------------------------------------------------------

echo "Running !Script_File!"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "!Script_Path!"' -Verb RunAs}";
ENDLOCAL DISABLEDELAYEDEXPANSION