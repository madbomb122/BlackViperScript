@ECHO OFF

:: Instructions
:: Bat, Script MUST be in same Folder
:: Change RunOption to = what you want to run (just the number)

Set Black_Viper=0
:: 0 = Run with Menu
:: 1 = Run with Windows Default Service Configuration
:: 2 = Run with Black Viper Safe
:: 3 = Run with Black Viper Tweaked

:: Change these to yes or no
Set Accept_TOS=no
Set Automated=no 

:: Update Checks   
:: If %update is found it will Auto-download and use that (with your settings)       
Set Script=No
Set Service=No
Set Internet_Check=yes 
:: ^only matters If %script or service is yes or github.com is blocked

:: Skip Script Check
:: SKIP AT YOUR OWN RISK
Set Skip_Build_Check=No
Set Skip_Edition_Check=No

::----------------------------------------------------------------------
:: Do not change unless you know what you are doing
Set Script_File=BlackViper-Win10.ps1
Set Script_Directory=%~dp0
Set Script_Path=%Script_Directory%%Script_File%

:: DO NOT CHANGE ANYTHING PAST THIS LINE
::----------------------------------------------------------------------
::Set Run_Option=

SETLOCAL ENABLEDELAYEDEXPANSION
If %Accept_TOS%==yes Set Run_Option=!Run_Option!-atos 

If %Black_Viper%==1 Set Run_Option=!Run_Option!-default 

If %Black_Viper%==2 Set Run_Option=!Run_Option!-safe 

If %Black_Viper%==3 Set Run_Option=!Run_Option!-tweaked 

If %Skip_Build_Check%==yes Set Run_Option=!Run_Option!-sbc 

If %Skip_Edition_Check%==yes Set Run_Option=!Run_Option!"-sec 

If %Internet_Check%==no Set Run_Option=!Run_Option!-sic 

If %Script%==yes Set Run_Option=!Run_Option!-usc 

If %Service%==yes Set Run_Option=!Run_Option!-use 

If %Automated%==yes Set Run_Option=!Run_Option!-auto 

echo !Run_Option!
echo "Running !Script_File!"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "!Script_Path! !Run_Option!"' -Verb RunAs}";
ENDLOCAL DISABLEDELAYEDEXPANSION