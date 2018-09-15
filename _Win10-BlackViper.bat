@ECHO OFF
:: Version 1.4
:: September 14, 2018

:: Instructions
:: Bat, Script MUST be in same Folder
:: Change Option to = one of the listed options (mostly yes or no)

Set Black_Viper=0
:: 0 = Run script and goto Gui (if no run settings are given)
:: 1 = Run with Windows Default Service Configuration
:: 2 = Run with Black Viper Safe
:: 3 = Run with Black Viper Tweaked

Set All_or_Min=0
:: 0 = run using script settings
:: all = Changes all windows services
:: min = Changes just the services that are different from default to tweaked/safe

Set Skip_XBox_Services=no
:: no = change xbox services
:: yes = skip xbox services

Set Stop_Disabled=no
:: no = Dont change running status
:: yes = Stop services that are disabled

Set ChangeState=no
:: no = Dont Change State of service to specified/loaded
:: yes = Change State of service to specified/loaded

Set Accept_ToS=no
:: no = See ToS
:: yes = Skip ToS (You accepted it)

Set Automated=no
:: no = Pause on - User input, On Errors, or End of Script
:: yes = Close on - User input, On Errors, or End of Script
:: yes, Implies that you accept the "ToS"

Set Backup_Current_Service_Conf=no
:: no = Dont backup Your Current Service Configuration before services are changes
:: yes = Backup Your Current Service Configuration before services are changes
Set Backup_Current_Service_Type=csv
:: csv = Save service backup as csv file
:: reg = Save service backup as reg file
:: both = Save service backup as csv and reg file
:: Filename will be "(ComputerName)-Service-Backup.csv"
:: Filename will be "(ComputerName)-Service-Backup.reg"

Set Load_Custom_Service_Config=no
:: no = Use the default Black Viper Service Configuration
:: yes = Use a Custom/Backup Service Configuration 
Set Service_Config_File=Computername-Service-Backup.csv
:: Set filename if being used otherwise ignore

Set Run_Dry=no
:: no = Runs script normaly
:: yes = Runs script and shows what will be changed

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
:: no = Dont skip Edition Check
:: Pro = Skips Edition Check and Sets Edition as Pro
:: Home = Skips Edition Check and Sets Edition as Home

:: Log file
Set Log=no
Set LogFile=Script.log

Set Log_Before_After=no
:: Make a file of all the services before and after the script
:: File will be in same directory as script named `Services-Before.log` and `Services-After.log`

:: Diagnostic Output (Dont use unless asked)
Set Diagnostic=no
Set Diagnostic_Log=no
Set Diagnostic_Force=no

::----------------------------------------------------------------------
:: Do not change unless you know what you are doing
Set Script_File=BlackViper-Win10.ps1
Set Script_Directory=%~dp0
Set Script_Path=%Script_Directory%%Script_File%

:: DO NOT CHANGE ANYTHING PAST THIS LINE
::----------------------------------------------------------------------
Set Show_Already_Set=no
Set Show_Not_Installed=no
Set Show_Skipped=no
Set Show_Switches=no
Set Show_Copyright=no

SETLOCAL ENABLEDELAYEDEXPANSION
If /i not "%*"=="" (
	for %%i in (%*) do (
		If /i !LoadServiceArg!==yes (
			Set Service_Config_File=%%i
			Set LoadServiceArg=no
		)
		If /i %%i==-lcsc Set LoadServiceArg=yes

		If /i %%i==-bscc (
			Set Backup_Current_Service_Conf=yes
			Set Backup_Current_Service_Type=csv
		)

		If /i %%i==-bscr (
			Set Backup_Current_Service_Conf=yes
			Set Backup_Current_Service_Type=reg
		)

		If /i %%i==-bscb (
			Set Backup_Current_Service_Conf=yes
			Set Backup_Current_Service_Type=both
		)
		If /i %%i==-dry Set Run_Dry=yes
		If /i %%i==-sss Set Show_Skipped=yes
		If /i %%i==-sas Set Show_Already_Set=yes
		If /i %%i==-snis Set Show_Not_Installed=yes
		If /i %%i==-sxb Set Skip_XBox_Services=yes
		If /i %%i==-atos Set Accept_ToS=yes
		If /i %%i==-auto Set Automated=yes
		If /i %%i==-usc Set Script=yes
		If /i %%i==-use Set Service=yes
		If /i %%i==-sic Set Internet_Check=no
		If /i %%i==-sbc Set Skip_Build_Check=yes
		If /i %%i==-sec Set Skip_Edition_Check=Pro
		If /i %%i==-secp Set Skip_Edition_Check=Pro
		If /i %%i==-sech Set Skip_Edition_Check=Home
		If /i %%i==-default Set Black_Viper=1
		If /i %%i==-safe Set Black_Viper=2
		If /i %%i==-tweaked Set Black_Viper=3
		If /i %%i==-diag Set Diagnostic=yes
		If /i %%i==-log Set Log=Yes
		If /i %%i==-baf Set Log_Before_After=yes
		If /i %%i==-sds Set Stop_Disabled=yes
		If /i %%i==-css Set ChangeState=yes	
		If /i %%i==-min Set All_or_Min=Min
		If /i %%i==-all Set All_or_Min=All
		If /i %%i==-devl Set Diagnostic_Log=yes
		If /i %%i==-help Set Show_Switches=yes
		If /i %%i==-copy Set Show_Copyright=yes
		If /i %%i==-diagf Set Diagnostic_Force=yes
	)
)

If /i %Stop_Disabled%==yes Set Run_Option=!Run_Option! -sds
If /i %ChangeState%==yes Set Run_Option=!Run_Option! -css

If /i %Accept_ToS%==yes Set Run_Option=!Run_Option! -atos

If /i %Black_Viper%==1 Set Run_Option=!Run_Option! -default
If /i %Black_Viper%==default Set Run_Option=!Run_Option! -default

If /i %Black_Viper%==2 Set Run_Option=!Run_Option! -safe
If /i %Black_Viper%==safe Set Run_Option=!Run_Option! -safe

If /i %Black_Viper%==3 Set Run_Option=!Run_Option! -tweaked
If /i %Black_Viper%==tweaked Set Run_Option=!Run_Option! -tweaked

If /i %All_or_Min%==All Set Run_Option=!Run_Option! -all
If /i %All_or_Min%==Min Set Run_Option=!Run_Option! -min

If /i %Skip_XBox_Services%==yes Set Run_Option=!Run_Option! -sxb
If /i %Show_Already_Set%==yes Set Run_Option=!Run_Option! -sas
If /i %Show_Not_Installed%==yes Set Run_Option=!Run_Option! -snis
If /i %Show_Skipped%==yes Set Run_Option=!Run_Option! -sss
If /i %Run_Dry%==yes Set Run_Option=!Run_Option! -dry
If /i %Diagnostic_Log%==yes Set Run_Option=!Run_Option! -devl
If /i %Show_Switches%==yes Set Run_Option=!Run_Option! -help
If /i %Show_Copyright%==yes Set Run_Option=!Run_Option! -copy
If /i %Diagnostic_Force%==yes Set Run_Option=!Run_Option! -diagf

If /i %Backup_Current_Service_Conf%==yes (
	If /i %Backup_Current_Service_Type%==csv Set Run_Option=!Run_Option! -bscc
	If /i %Backup_Current_Service_Type%==reg Set Run_Option=!Run_Option! -bscr
	If /i %Backup_Current_Service_Type%==both Set Run_Option=!Run_Option! -bscb
)

If /i %Load_Custom_Service_Config%==yes Set Run_Option=!Run_Option! -lcsc %Service_Config_File%

If /i %Skip_Build_Check%==yes Set Run_Option=!Run_Option! -sbc

If /i %Skip_Edition_Check%==Pro Set Run_Option=!Run_Option! -secp
If /i %Skip_Edition_Check%==Home Set Run_Option=!Run_Option! -sech

If /i %Internet_Check%==no Set Run_Option=!Run_Option! -sic

If /i %Script%==yes Set Run_Option=!Run_Option! -usc

If /i %Service%==yes Set Run_Option=!Run_Option! -use

If /i %Automated%==yes Set Run_Option=!Run_Option! -auto

If /i %Diagnostic%==yes Set Run_Option=!Run_Option! -diag

If /i %Log_Before_After%==yes Set Run_Option=!Run_Option! -baf

If /i %Log%==yes Set Run_Option=!Run_Option! -log %LogFile%

echo "Running !Script_File!"
PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& '!Script_Path!' !Run_Option!" -Verb RunAs
ENDLOCAL DISABLEDELAYEDEXPANSION
