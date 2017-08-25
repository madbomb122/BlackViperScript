@echo off
:: Version 1.0
:: August 25th, 2017

SETLOCAL ENABLEDELAYEDEXPANSION

Set FileDir=%~dp0
Set URL_Base=https://raw.githubusercontent.com/madbomb122/
Set UpdateArg=no
Set RunArg=no
Set DownloadBV=no
Set DownloadW10=no
Set DownloadBV-W10=no
Set Test=no
Set MiscArg=

if [%1]==[] (
	goto Menu
) else (
	goto loop
)

:loop
if x%1 equ x (
	If /i %DownloadBV-W10%==yes goto BV
	If /i %DownloadBV%==yes goto BV
	If /i %DownloadW10%==yes goto W10
	goto Invalid
)
set param=%1
goto checkParam

:next
shift /1
goto loop

:checkParam
If "%1" equ "-help" goto ShowArgs
If "%1" equ "-u" (
	Set UpdateArg=yes
	goto next
)
If "%1" equ "-r" (
	Set RunArg=yes
	goto next
)
If "%1" equ "-bv" (
	Set DownloadBV=yes
	goto next
)
If "%1" equ "-w10" (
	Set DownloadW10=yes
	goto next
)
If "%1" equ "-both" (
	Set DownloadBV-W10=yes
	goto next
)
If "%1" equ "-test" (
	Set Test=yes
	goto next
)
Set MiscArg=!MiscArg! %1
goto next


:BV
	Set ScriptFileName=BlackViper-Win10.ps1
	Set FilePath=!FileDir!!ScriptFileName!
	Set ScriptUrl=!URL_Base!BlackViperScript/master/
	If /i %Test%==yes Set ScriptUrl=!ScriptUrl!Testing/
	Set ScriptUrl=!ScriptUrl!!ScriptFileName!
	echo.
	echo Downloading Black Viper Script
	echo from !ScriptUrl!
	echo to !FilePath!
	echo.
	powershell -Command "Invoke-WebRequest !ScriptUrl! -OutFile !FilePath!"
	If /i %UpdateArg%==no (
		Set ServiceFilePath=!FileDir!BlackViper.csv
		Set ServiceUrl=!URL_Base!BlackViperScript/master/BlackViper.csv
		powershell -Command "Invoke-WebRequest !ServiceUrl! -OutFile !ServiceFilePath!"
	)
	goto CheckRun

:W10
	Set ScriptFileName=Win10-Menu.ps1
	Set FilePath=!FileDir!!ScriptFileName!
	Set ScriptUrl=!URL_Base!Win10Script/master/
	If /i %Test%==yes Set ScriptUrl=!ScriptUrl!Testing/
	Set ScriptUrl=!ScriptUrl!!ScriptFileName!
	echo.
	echo Downloading Windows 10 Script
	echo from !ScriptUrl!
	echo to !FilePath!
	echo.
    powershell -Command "Invoke-WebRequest !ScriptUrl! -OutFile !FilePath!"
	If /i %DownloadBV-W10%==yes set DownloadBV-W10=Done
	goto CheckRun


:Invalid
	echo No valid Argument/Switch was used,
	goto ShowArgs

:ShowArgs
	echo The following is a list of valid Argument/Switch
	echo.
	echo Switch    Description
	echo -----------------------------------------------------------------
	echo -Help     Shows the Argument/Switch
	echo -BV       Download BlackViper Script
	echo -W10      Download Windows 10 Script
	echo -Both     Download BlackViper and Windows 10 Script
	echo -Test     Download the Test Version of Script
	echo -Run      Download then runs the script..Does not work with -Both
	GOTO:EOF

:CheckRun
	If /i %DownloadBV-W10%==yes goto W10
	If /i %UpdateArg%==yes (
		PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "!FilePath! !MiscArg!"' -Verb RunAs}"
		Exit
	)
	If /i %RunArg%==yes (
		If /i %DownloadBV-W10%==Done (
			echo Cannot do a -Run with -Both
		) else (
			PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "!FilePath!"' -Verb RunAs}"
		)
		Exit
	)
	GOTO:EOF

:Menu
cls
echo      ******************************************************
echo      *                                                    *
echo      *       Madbomb122's Script Updater/Downloader       *
echo      *                                                    *
echo      ******************************************************
echo      *                                                    *
echo      *   Stable Version                                   *
echo      *  ------------------------                          *
echo      *   A) Black Viper Script*                           *
echo      *   B) Windows 10 Script                             *
echo      *   C) Black Viper ^& Windows 10 Script               *
echo      *                                                    *
echo      *   Test Version                                     *
echo      *  ------------------------                          *
echo      *   D) Black Viper Script*                           *
echo      *   E) Windows 10 Script                             *
echo      *   F) Black Viper ^& Windows 10 Script               *
echo      *                                                    *
echo      *  ------------------------                          *
echo      *   Q) Quit                                          *
echo      *                                                    *
echo      *  *Note: Will also download the Service file for    *
echo      *            Black Viper Script.                     *
echo      ******************************************************
CHOICE /C ABCDEFQ /N /M "Please Input Choice:"
IF %ERRORLEVEL%==1 goto BV
IF %ERRORLEVEL%==2 goto W10
IF %ERRORLEVEL%==3 (
	Set DownloadBV-W10=yes
	goto BV 
)
IF %ERRORLEVEL%==4 (
	Set Test=yes
	goto BV 
)
IF %ERRORLEVEL%==5 (
	Set Test=yes
	goto W10 
)
IF %ERRORLEVEL%==6 (
	Set DownloadBV-W10=yes
	Set Test=yes
	goto BV 
)
IF %ERRORLEVEL%==7 GOTO:EOF

ENDLOCAL DISABLEDELAYEDEXPANSION