@Echo off
:: Version 1.2
:: September 1st, 2017

SETLOCAL ENABLEDELAYEDEXPANSION

Set FileDir=%~dp0
Set URL_Base=https://raw.githubusercontent.com/madbomb122/
Set UpdateArg=no
Set RunArg=no
Set DownloadBV=no
Set BVScript=no
Set DownloadW10=no
Set W10Script=no
Set DownloadBV-W10=no
Set CheckUpdateBoth=no
Set BatDownload=no
Set TestV=no
Set MiscArg=

if [%1]==[] (
	goto Check4Script
) else (
	goto Loop
)

:Loop
if x%1 equ x (
	Echo.
	If /i %DownloadBV%==yes If /i %DownloadW10%==yes (
		Set DownloadBV-W10=yes
		Set DownloadBV=no
		Set DownloadW10=no
	)
	If /i %DownloadBV-W10%==yes goto BV
	If /i %DownloadBV%==yes goto BV
	If /i %DownloadW10%==yes goto W10
	goto Invalid
)
set param=%1
goto CheckParam

:Next
shift /1
goto Loop

:CheckParam
If /i %1==-help goto ShowArgs
If /i %1==-h goto ShowArgs
If /i %1==-u (
	Set UpdateArg=yes
	goto Next
)
If /i %1==-r (
	Set RunArg=yes
	goto Next
)
If /i %1==-bv (
	Set DownloadBV=yes
	goto Next
)
If /i %1==-w10 (
	Set DownloadW10=yes
	goto Next
)
If /i %1==-both (
	Set DownloadBV-W10=yes
	goto Next
)
If /i %1==-test (
	Set TestV=yes
	goto Next
)
Set MiscArg=!MiscArg! %1
goto Next

:BV
	Set ScriptFileName=BlackViper-Win10.ps1
	Set FilePath=%FileDir%%ScriptFileName%
	Set ScriptUrl=!URL_Base!BlackViperScript/master/
	If /i %TestV%==yes Set ScriptUrl=!ScriptUrl!Testing/
	Set ScriptUrl=!ScriptUrl!%ScriptFileName%
	Echo Downloading Black Viper Script
	::Echo from !ScriptUrl!
	Echo to %FilePath%
	Echo.
	powershell -Command "Invoke-WebRequest !ScriptUrl! -OutFile %FilePath%"
	If /i %UpdateArg%==no (
		Set ServiceFilePath=%FileDir%BlackViper.csv
		Set ServiceUrl=!URL_Base!BlackViperScript/master/BlackViper.csv
		Echo Downloading Black Viper Service File
		::Echo from !ServiceUrl!
		Echo to !ServiceFilePath!
		Echo.
		powershell -Command "Invoke-WebRequest !ServiceUrl! -OutFile !ServiceFilePath!"
		If %BatDownload%==yes (
			Set BatFilePath=%FileDir%_Win10-BlackViper.bat
			Set BatUrl=!URL_Base!BlackViperScript/master/_Win10-BlackViper.bat
			Echo Downloading Black Viper Script Bat File
			::Echo from !BatUrl!
			Echo to !BatFilePath!
			Echo.
			powershell -Command "Invoke-WebRequest !BatUrl! -OutFile !BatFilePath!"
		)
	)
	goto CheckRun

:BVLocalVer
	Set BVCount=0
	Set LocalBaseVerBV=0
	Set LocalSubVerBV=0
	Set BVTest=no
	Echo Checking if Update is aviable for BlackViper Script...
	For /F "tokens=1 delims=$" %%G IN (BlackViper-Win10.ps1) DO (
		Set /a BVCount=!BVCount!+1
		If !BVCount!==12 (
			Set LocalBaseVerBV=%%G
			Set LocalBaseVerBV=%LocalBaseVerBV:~18,3%
		)
		If !BVCount!==13 (
			Set LocalSubVerBV=%%G
			Set LocalSubVerBV=%LocalSubVerBV:~17,1%
		)
		If !BVCount!==15 (
			Set BVTemp=%%G
			Set BVTemp=%BVTemp:~16,1%
			If %BVTemp%==T Set BVTest=yes
			goto BVWebVer
		)
	)

:BVWebVer
	Set BVuCount=0
	Set WebBaseVerBV=0
	Set WebSubVerBV=0
	powershell -Command "Invoke-WebRequest "%URL_Base%BlackViperScript/master/Version/Version.csv" -OutFile %Temp%\BV-Ver.csv"
	For /F "tokens=*" %%G IN (%Temp%\BV-Ver.csv) DO (
		If /i %BVTest%==no (
			If !BVuCount!==1 (
				Set WebBaseVerBVT=%%G
				Set WebBaseVerBV=%WebBaseVerBVT:~17,3%
				Set WebSubVerBV=%WebBaseVerBVT:~21,1%
			)
		) Else (
			If !BVuCount!==3 (
				Set WebBaseVerBVT=%%G
				Set WebBaseVerBV=%WebBaseVerBVT:~17,3%
				Set WebSubVerBV=%WebBaseVerBVT:~21,1%
			)
		)
		Set /a BVuCount=!BVuCount!+1
	)
	If %LocalBaseVerBV% lss %WebBaseVerBV% Set DownloadBV=yes
	If %LocalBaseVerBV%==%WebBaseVerBV% If %LocalSubVerBV% lss %WebSubVerBV% Set DownloadBV=yes
	If /i %DownloadBV%==yes (
		::Echo Test = %BVTest%
		Echo Your BlackViper Script V.%LocalBaseVerBV%.%LocalSubVerBV%
		Echo Latest BlackViper Script V.%WebBaseVerBV%.%WebSubVerBV%
		Echo.
	) Else (
		Echo Your BlackViper Script V.%LocalBaseVerBV%.%LocalSubVerBV% is the latest version
	)
	goto BV

:W10
	Set ScriptFileName=Win10-Menu.ps1
	Set FilePath=%FileDir%%ScriptFileName%
	Set ScriptUrl=!URL_Base!Win10Script/master/
	If /i %TestV%==yes Set ScriptUrl=!ScriptUrl!Testing/
	Set ScriptUrl=!ScriptUrl!%ScriptFileName%
	Echo Downloading Windows 10 Script
	::Echo from !ScriptUrl!
	Echo to %FilePath%
	Echo.
	powershell -Command "Invoke-WebRequest !ScriptUrl! -OutFile %FilePath%"
	If %BatDownload%==yes (
		Set BatFilePath=%FileDir%_Win10-Script-Run.bat
		Set BatUrl=!URL_Base!Win10Script/master/_Win10-Script-Run.bat
		Echo Downloading Windows 10 Script Bat File
		::Echo from !BatUrl!
		Echo to !BatFilePath!
		Echo.
		powershell -Command "Invoke-WebRequest !BatUrl! -OutFile !BatFilePath!"
	)
	If /i %DownloadBV-W10%==yes set DownloadBV-W10=Done
	goto CheckRun

:W10LocalVer
	Set W10Count=0
	Set LocalBaseVerW10=0
	Set LocalSubVerW10=0
	Set W10Test=no
	Echo Checking if Update is aviable for BlackViper Script...
	For /F "tokens=1 delims=$" %%G IN (Win10-Menu.ps1) DO (
		Set /a W10Count=!W10Count!+1
		If !W10Count!==13 (
			Set LocalBaseVerW10=%%G
			Set LocalBaseVerW10=%LocalBaseVerW10:~18,3%
		)
		If !W10Count!==14 (
			Set LocalSubVerW10=%%G
			Set LocalSubVerW10=%LocalSubVerW10:~17,1%
		)
		If !W10Count!==16 (
			Set W10Temp=%%G
			Set W10Temp=%W10Temp:~16,1%
			If %W10Temp%==T Set W10Test=yes
			goto W10WebVer
		)
	)

:W10WebVer
	Set W10uCount=0
	Set WebBaseVerW10=0
	Set WebSubVerW10=0
	powershell -Command "Invoke-WebRequest "%URL_Base%Win10Script/master/Version/Version.csv" -OutFile %Temp%\W10-Ver.csv"
	For /F "tokens=*" %%G IN (%Temp%\W10-Ver.csv) DO (
		If /i %W10Test%==no (
			If !W10uCount!==1 (
				Set WebBaseVerW10T=%%G
				Set WebBaseVerW10=%WebBaseVerW10T:~7,3%
				Set WebSubVerW10=%WebBaseVerW10T:~11,1%
			)
		) Else (
			If !W10uCount!==2 (
				Set WebBaseVerW10T=%%G
				Set WebBaseVerW10=%WebBaseVerW10T:~5,3%
				Set WebSubVerW10=%WebBaseVerW10T:~9,1%
			)
		)
		Set /a W10uCount=!W10uCount!+1
	)
	If %LocalBaseVerW10% lss %WebBaseVerW10% Set DownloadW10=yes
	If %LocalBaseVerW10%==%WebBaseVerW10% If %LocalSubVerW10% lss %WebSubVerW10% Set DownloadW10=yes
	If /i %DownloadW10%==yes (
		::Echo Test = %BVTest%
		Echo Your Windows 10 Script V.%LocalBaseVerW10%.%LocalSubVerW10%
		Echo Latest Windows 10 Script V.%WebBaseVerW10%.%WebSubVerW10%
		Echo.
	) Else (
		Echo Your Windows 10 Script V.%LocalBaseVerW10%.%LocalSubVerW10% is the latest version
	)
	goto CheckRun

:Invalid
	Echo No valid Argument/Switch was used,
	goto ShowArgs

:ShowArgs
	Echo The following is a list of valid Argument/Switch
	Echo.
	Echo Switch    Description
	Echo -----------------------------------------------------------------
	Echo -Help     Shows the Argument/Switch
	Echo -BV       Download BlackViper Script
	Echo -W10      Download Windows 10 Script
	Echo -Both     Download BlackViper and Windows 10 Script
	Echo -Test     Download the Test Version of Script
	Echo -Run      Download then runs the script..Does not work with -Both
	goto:EOF

:CheckRun
	If %CheckUpdateBoth%==yes (
		Set CheckUpdateBoth=no
		goto W10LocalVer
	)
	If /i %DownloadBV-W10%==yes goto W10
	If /i %UpdateArg%==yes (
		powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "%FilePath% !MiscArg!"' -Verb RunAs}"
		Exit
	)
	If /i %RunArg%==yes (
		If /i %DownloadBV-W10%==Done (
			Echo Cannot do a -Run with -Both
		) else (
			powershell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File "%FilePath%"' -Verb RunAs}"
		)
		Exit
	)
	goto:EOF

:Check4Script
Set BVW10Script=0
If Exist %FileDir%BlackViper-Win10.ps1 (
	Set BVScript=yes 
	Set /a BVW10Script=!BVW10Script!+1
	Echo BVW10Script=!BVW10Script! - BV
)
If Exist %FileDir%Win10-Menu.ps1 (
	Set W10Script=yes
	Set /a BVW10Script=!BVW10Script!+1
	Echo BVW10Script=!BVW10Script! - W10
)
goto MainMenu


:MainMenu
cls
Echo  ----------------------------------------------------------------------------
Echo  ^|________________  Madbomb122's Script Updater/Downloader  ________________^|
Echo  ^|                ------------------------------------------                ^|
Echo  ^|                                                                          ^|
If /i %TestV%==no (
	Echo  ^|                              Stable Version                              ^|
) Else (
	Echo  ^|                               Test Version                               ^|
)
Echo  ^|                  --------------------------------------                  ^|
If /i %BatDownload%==no (
	Echo  ^|                    1^) Black Viper Script*                                ^|
	Echo  ^|                    2^) Windows 10 Script                                  ^|
	Echo  ^|                    3^) Black Viper ^& Windows 10 Script                    ^|
) Else (
	Echo  ^|                    1^) Black Viper Script* ^& Bat File                     ^|
	Echo  ^|                    2^) Windows 10 Script ^& Bat File                       ^|
	Echo  ^|                    3^) Black Viper ^& Windows 10 Script ^& Bat Files        ^|
)
Echo  ^|                                                                          ^|
Echo  ^|                        Download Options (Toggles)                        ^|
Echo  ^|                  --------------------------------------                  ^|
If /i !TestV!==no (
	Echo  ^|                    4^) Dont Download Test Version ^(Stable^) of Script      ^|
) Else (
	Echo  ^|                    4^) Download Test Version of Script                    ^|
)
If /i %BatDownload%==no (
	Echo  ^|                    5^) Dont Download bat file                             ^|
) Else (
	Echo  ^|                    5^) Download bat file                                  ^|
)
If /i !RunArg!==no (
	Echo  ^|                    6^) Dont Run Script after download**                   ^|
) Else (
	Echo  ^|                    6^) Run A Script after download**                      ^|
)
If NOT !BVW10Script!==0 (
	Echo  ^|                                                                          ^|
	Echo  ^|                               Check Update                               ^|
	Echo  ^|                  --------------------------------------                  ^|
	If !BVW10Script!==2 (
		Echo  ^|                    7^) Black Viper Script ^& Serivce                       ^|
		Echo  ^|                    8^) Windows 10 Script                                  ^|
		Echo  ^|                    9^) Black Viper ^& Windows 10 Script                    ^|
	) Else (
		If %BVScript%==yes 	Echo  ^|                    7^) Black Viper Script ^& Serivce                       ^|
		If %W10Script%==yes Echo  ^|                    7^) Windows 10 Script                                  ^|
	)
)
Echo  ^|                                                                          ^|
Echo  ^|                  --------------------------------------                  ^|
Echo  ^|                    Q^) Quit                                               ^|
Echo  ^|                                                                          ^|
Echo  ^|  *Note: Will also download the Service file for Black Viper Script.      ^|
Echo  ^|  **Note: Will NOT Run Script if downloading both Scripts. ^(Option 3^)     ^|
Echo  ^|__________________________________________________________________________^|
Echo.
CHOICE /C 123456789Q /N /M "Please Input Choice:"
IF %ERRORLEVEL%==1 goto BV
IF %ERRORLEVEL%==2 goto W10
IF %ERRORLEVEL%==3 (
	Set DownloadBV-W10=yes
	goto BV 
)
IF %ERRORLEVEL%==4 (
	If !TestV!==no (
		Set TestV=yes
	) Else (
		Set TestV=no
	)
	goto MainMenu
)
IF %ERRORLEVEL%==5 (
	If %BatDownload%==no (
		Set BatDownload=yes
	) Else (
		Set BatDownload=no
	)
	goto MainMenu
)
IF %ERRORLEVEL%==6 (
	If /i !RunArg!==no (
		Set RunArg=yes
	) Else (
		Set RunArg=no
	)
	goto MainMenu
)
IF %ERRORLEVEL%==7 (
	If NOT !BVW10Script!==0 ( 
		If %BVScript%==yes (
			goto BVLocalVer
		) Else (
			goto W10LocalVer
		)
	)
	goto:EOF
)
IF %ERRORLEVEL%==8 (
	If !BVW10Script!==2 goto W10LocalVer
	goto:EOF
)
IF %ERRORLEVEL%==9 (
	If !BVW10Script!==2 (
		Set CheckUpdateBoth=yes
		goto BVLocalVer
	)
	goto:EOF
)
IF %ERRORLEVEL%==10 goto:EOF

ENDLOCAL DISABLEDELAYEDEXPANSION
