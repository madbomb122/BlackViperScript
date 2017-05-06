@ECHO OFF
:: Instructions
:: Bat, Script MUST be in same Folder
:: Change Option to = one of the listed options (mostly yes or no)

Set Black_Viper=0
:: 0 = Run with Menu
:: 1 = Run with Windows Default Service Configuration
:: 2 = Run with Black Viper Safe
:: 3 = Run with Black Viper Tweaked

:: Change these to yes or no
Set Accept_ToS=no
:: no = See ToS
:: yes = Skip ToS (You accepted it)

Set Automated=no
:: no = Pause on - User input, On Errors, or End of Script
:: yes = Close on - User input, On Errors, or End of Script
:: yes, Implies that you accept the "ToS"

:: Update Checks   
:: If update is found it will Auto-download and use that (with your settings)       
Set Script=no
Set Service=no
Set Internet_Check=yes 
:: Internet_Check only matters If Script or Service is yes and pings to github.com is blocked

:: Skip Script Check
:: SKIP AT YOUR OWN RISK
Set Skip_Build_Check=no
Set Skip_Edition_Check=no

:: Diagnostic Output (Wont run script)
Set Diag=no

::----------------------------------------------------------------------
:: Do not change unless you know what you are doing
Set Script_File=BlackViper-Win10.ps1
Set Script_Directory=%~dp0
Set Script_Path=%Script_Directory%%Script_File%

:: DO NOT CHANGE ANYTHING PAST THIS LINE
::----------------------------------------------------------------------
SETLOCAL ENABLEDELAYEDEXPANSION

If /i not "%*"=="" (
    for %%i in (%*) do (
        If /i !SetArg!==yes (
            If /i %%i==default Set Black_Viper=1
            If /i %%i==safe Set Black_Viper=2
            If /i %%i==tweaked Set Black_Viper=3
            If /i %%i==1 Set Black_Viper=1
            If /i %%i==2 Set Black_Viper=2
            If /i %%i==3 Set Black_Viper=3
            Set SetArg=no
        )
        If /i %%i==-atos Set Accept_ToS=yes
        If /i %%i==-auto Set Automated=yes
        If /i %%i==-usc Set Script=yes
        If /i %%i==-use Set Service=yes
        If /i %%i==-sic Set Internet_Check=yes
        If /i %%i==-sbc Set Skip_Build_Check=yes
        If /i %%i==-sec Set Skip_Edition_Check=yes
        If /i %%i==-default Set Black_Viper=1
        If /i %%i==-safe Set Black_Viper=2
        If /i %%i==-tweaked Set Black_Viper=3
        If /i %%i==-diag Set Diag=yes
        If /i %%i==-Set Set SetArg=yes
    )
)

If /i %Accept_ToS%==yes Set Run_Option=!Run_Option! -atos

If /i %Black_Viper%==1 Set Run_Option=!Run_Option! -default
If /i %Black_Viper%==default Set Run_Option=!Run_Option! -default

If /i %Black_Viper%==2 Set Run_Option=!Run_Option! -safe
If /i %Black_Viper%==safe Set Run_Option=!Run_Option! -safe

If /i %Black_Viper%==3 Set Run_Option=!Run_Option! -tweaked
If /i %Black_Viper%==tweaked Set Run_Option=!Run_Option! -tweaked

If /i %Skip_Build_Check%==yes Set Run_Option=!Run_Option! -sbc

If /i %Skip_Edition_Check%==yes Set Run_Option=!Run_Option! -sec

If /i %Internet_Check%==no Set Run_Option=!Run_Option! -sic

If /i %Script%==yes Set Run_Option=!Run_Option! -usc

If /i %Service%==yes Set Run_Option=!Run_Option! -use

If /i %Automated%==yes Set Run_Option=!Run_Option! -auto

If /i %Diag%==yes Set Run_Option=!Run_Option! -diag

echo "Running !Script_File!"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "!Script_Path! !Run_Option!"' -Verb RunAs}";
ENDLOCAL DISABLEDELAYEDEXPANSION
