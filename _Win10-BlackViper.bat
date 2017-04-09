@ECHO OFF

:: Instructions
:: Bat, Script MUST be in same Folder
:: Change RunOption to = what you want to run (just the number)

set Run_Option=0
:: Anything other than following does nothing
:: 0 = Run with Menu
:: 1 = Run with Windows Default Service Configuration
:: 2 = Run with Black Viper Safe
:: 3 = Run with Black Viper Tweaked
:: 4 = Exit (Dont Run script)

set Script_File=BlackViper-Win10.ps1

:: Do not change unless you know what you are doing
set Script_Directory=%~dp0
set Script_Path=%Script_Directory%%Script_File%

:: DO NOT CHANGE ANYTHING PAST THIS LINE
::----------------------------------------------------------------------
set Use_Arg=yes

if /i %Run_Option%==0 set Use_Arg=no
if /i %Run_Option%==4 Exit

SETLOCAL ENABLEDELAYEDEXPANSION
if /i %Use_Arg%==no (
    powershell.exe -noprofile -ExecutionPolicy Bypass -command "&{start-process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -file \"!Script_Path!\"' -verb RunAs}"
)
ENDLOCAL DISABLEDELAYEDEXPANSION

SETLOCAL ENABLEDELAYEDEXPANSION
if /i %Use_Arg%==yes (
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"!Script_Path!\" -Set \"!Run_Option!\"' -Verb RunAs}";
)
ENDLOCAL DISABLEDELAYEDEXPANSION
