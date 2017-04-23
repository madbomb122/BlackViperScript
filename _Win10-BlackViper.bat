@ECHO OFF

:: Instructions
:: Bat, Script MUST be in same Folder
:: Change RunOption to = what you want to run (just the number)

Set Run_Option=0
:: Anything other than following does nothing
:: 0 = Run with Menu
:: 1 = Run with Windows Default Service Configuration
:: 2 = Run with Black Viper Safe
:: 3 = Run with Black Viper Tweaked
:: 4 = Exit (Dont Run script)

Set Script_File=BlackViper-Win10.ps1

:: Do not change unless you know what you are doing
Set Script_Directory=%~dp0
Set Script_Path=%Script_Directory%%Script_File%

:: DO NOT CHANGE ANYTHING PAST THIS LINE
::----------------------------------------------------------------------
Set Use_Arg=yes

If /i %Run_Option%==0 Set Use_Arg=no
If /i %Run_Option%==4 Exit
If /i %Run_Option%==5 Set Use_Arg=diag

SETLOCAL ENABLEDELAYEDEXPANSION
If /i %Use_Arg%==no (
    echo "Running !Script_File!, with Menu option"
    powershell.exe -noprofile -ExecutionPolicy Bypass -command "&{start-process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -file \"!Script_Path!\"' -verb RunAs}"
)
ENDLOCAL DISABLEDELAYEDEXPANSION

SETLOCAL ENABLEDELAYEDEXPANSION
If /i %Use_Arg%==yes (
    echo "Running !Script_File! -Set !Run_Option!"
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"!Script_Path!\" -Set \"!Run_Option!\"' -Verb RunAs}";
)
ENDLOCAL DISABLEDELAYEDEXPANSION

SETLOCAL ENABLEDELAYEDEXPANSION
If /i %Use_Arg%==diag (
    echo "Running !Script_File! to Show Diagnostic Output"
    PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"!Script_Path!\" -Set diag' -Verb RunAs}";
)
ENDLOCAL DISABLEDELAYEDEXPANSION
