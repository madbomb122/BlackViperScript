**Current Version** <br />
**Script:** `2.7.0` (June 21, 2017) <br />
**Service:** `2.0` (May 21, 2017) <br />

**Note: The 2.0+ Script/Service files wont work with versions older than 2.0 due to big changes**

# Description
Easy to use Script that can set Windows 10 services based on Black Viper's Service Configurations. <br />

Black Viper's Service Configurations from http://www.blackviper.com/

**Note 1: Script is ment for Windows 10 Home x64 / Windows 10 Pro x64.. With Creator's Update Installed**  <br />
**Note 2: If you are using a non english version of Windows and get a Build Check Error, please let me know**  <br />

PS. Don't forget to check out my other Repo https://github.com/madbomb122/Win10Script  <br />

# Requirements (Make sure to LOOK at this)

|            | Recommended Requirements         | AT YOURN OWN RISK* (See Note Bellow) |
| :--------- | :--------------------------------| :--------------------------- |
|**OS**      | Windows 10 x64                   | Windows 10 x32               |
|**Edition** | Pro or Home                      | All Others                   |
|**Build**   | Creator's Update                 | Pre-Creator's Update         |

<br />

**_Need Files_** <br />
`BlackViper-Win10.ps1` (Script) <br />
`BlackViper.csv` (Service Configurations) <br />

**Recommended Files** <br />
`_Win10-BlackViper.bat` (To run script easier) <br /> 
`README.md` (This Readme) <br />

**Note:**
**AT YOUR OWN RISK** <br />
**1. Run the script on x32 w/o changing settings (But shows a warning)** <br />
**2. Skip the check for** <br />
**---A. Home/Pro** *(`$Script:Edition_Check` variable in script or use `-sec` switch)* <br />
**---B. Creator's Update** *(`$Script:Build_Check` variable in script or use `-sbc` switch)* <br />

# How to Use/Run
Download/Save the following files <br />
Script File: `BlackViper-Win10.ps1` -Need <br />
Service Config File: `BlackViper.csv` -Need <br />
Bat File: `_Win10-BlackViper.bat` -Recommended <br />
  **Note: DO NOT RENAME THE FILES**<br />
Next follow the **Basic Usage** or **Advanced Usage**

# Basic_Usage
Run the Script by bat file `_Win10-BlackViper.bat` (Recommended) <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1` <br />
Select desired Services Configuration <br />
*1. Default <br />
2. Safe (Recommended Option) <br />
3. Tweaked (Not supported for laptop ATM)<br />*

# Advanced_Usage
Use one of the following Methods you can 
1. Run script or bat file with one (or more) of the switches bellow
2. Edit the script (bottom of file) to change the values
3. Edit the bat file (top of file) to change the values to add the switch


|   Switch  | Description                                                                    | Notes                            |
| :-------- | :------------------------------------------------------------------------------| :------------------------------- |
| -atos     | Accepts the ToS                                                                |                                  |
| -auto     | Runs the script to be Automated.. Closes on User input, Errors, End of Script) | Implies `-atos`                |
| -default  | Runs the script with Services to Default Configuration                         | Alt `-set default` or `-set 1` |
| -safe     | Runs the script with Services to Black Viper's Safe Configuration              | Alt `-set safe` or `-set 2`    |
| -tweaked  | Runs the script with Services to Black Viper's Tweaked Configuration           | Alt `-set tweaked` or `-set 3` |
| -all      | Every windows services will change                                             |   |
| -min      | Just the services different from the default to safe/tweaked list              |   |
| -bcsc     | Backup Current Service Configuration                      | Filename will be `COMPUTERNAME-Service-Backup.csv`   |
| -lcsc File.csv | Loads Custom Service Configuration                             | `File.csv` Name of backup/custom file |
| -sec      | Skips Edition Check (Home/Pro)                                                 | **USE AT YOUR OWN RISK**        |
| -secp     | Skips Edition Check (Home/Pro), Sets edition as Pro                            | **USE AT YOUR OWN RISK**        |
| -sech     | Skips Edition Check (Home/Pro), Sets edition as Home                           | **USE AT YOUR OWN RISK**        |
| -sbc      | Skips Build Check (Creator's Update)                                           | **USE AT YOUR OWN RISK**        |
| -sic      | Skips Internet Check (If checking for update)                                  | Tests by pinging github.com      |
| -usc      | Checks for Update to Script file before running                                | Auto downloads and runs if found |
| -use      | Checks for Update to Service file before running                               | Auto downloads and uses if found |
| -snis     | Shows not installed services (that can be changed)                             |  |
| -diag     | Shows some diagnostic information on error messages                            | **Stops automation** |
| -log      | Makes a log file (Logs Notices, Errors, & Services changed)                    | Log file `Script.log` (default) |
| -baf      | File of all the services before and after the script                 | `Services-Before.log` and `Services-After.log`    |
| -dry      | Runs script and shows what will be changed if ran normaly                     | **No Services are changes** |
| -devl     | Makes a log file with various Diagnostic information                          | **No Services are changes** |

Examples: <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -lcsc MyComp-Service-Backup.csv` <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -Set Default` <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -atos -use -set 2` <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -auto -use -tweaked -sec` <br />
`_Win10-BlackViper.bat -Set Default` <br />
`_Win10-BlackViper.bat -atos -use -set 2` <br />
`_Win10-BlackViper.bat -auto -use -tweaked -sec` <br />
******

# FAQ

**Q:** The script file looks all messy in notepad, How do i view it? <br />
**A:** Try using wordpad or what I recommend, Notepad++ https://notepad-plus-plus.org/

**Q:** Do you accept any donations? <br />
**A:** I'd rather you donate to Black Viper... but if you would like to donate to me I accept amazon giftcards (email it to me). <br />
**NOTE:** http://www.blackviper.com/support-bv/

**Q:** How can I contact you? <br />
**A:** You can email me @ madbomb122@gmail.com, if it's an issue please post under issue

**Q:** The script wont run, can you help me? <br />
**A:** Yes, but first if you are using automation.. turn off automation and see if it gives and error that you can correct.

**Q:** Please E-Mail me if you are getting an Edition error when running Home/Pro? <br />
**A:** E-Mail me what your edition is and what edition it says you are using, so I can add it to the list, Until then use -secp (for Pro) or -sech (for Home), Thanks.

**Q:** The script window closes or gives an error saying script is blocked, what do i do? <br />
**A:** By default windows blocks ps1 scripts, you can use one of the following <br />
         1. Use the bat file to run the script (recommended) <br />
         2. On an admin powershell console `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted` <br />	 

**Q:** Who do I contact about the Service Configurations or an issue with the configuration? <br />
**A:** Any "technical" issues (or why something is set one way or another) can be directed to Black Viper himself.

**Q:** Why does you script not change the service *BLAH*? <br />
**A:** You didnt select the All option, it's not a default windows service, cant be changed, or some other good reason.

**Q:** I have an issue with the script, what do I do? <br />
**A:** Post it as an issue using github's issues tab up top.

**Q:** Can I run the script safely? <br />
**A:** The script itself is safe, but changes to services may cause problems for certin programs.

**Q:** Can I run the script repeatedly? <br />
**A:** Yes, with same or different settings.

**Q:** I've run the script and it did *BLAH*, can I undo it? <br />
**A:** Yes, run the script again and select again. <br />

**Q:** Can I use the script or modify it for my / my company's needs? <br />
**A:** Sure. Just don't forget to include copyright notice as per the license requirements, and leave any Copyright in script too.

**Q:** The script messed up my computer. <br />
**A:** The script is as is, any problems you have/had is your own problem.

**Q:** Are you going to add support for other editions of Windows 10 other than Pro or Home? <br />
**A:** Sorry, I only support the windows 10 configuration listed on Black Viper's website. <br />

**Q:** Are you going to add support for builds before the "Creator's Update"? <br />
**A:** Sorry, since I dont have the configuration from before the "Creator's Update" I can't add it. <br />
**Note:** If you have the configuration please contact me.

**Q:** Will you make a script for any windows before windows 10? <br />
**A:** No. <br />

**Q:** Can I download the csv file from Black Viper's website and use that? <br />
**A:** No, my file is not the same. <br />

**Q:** Can I add a service to be changed or stop one from changing? <br />
**A:** Yes, to add/remove edit the file `BlackViper.csv` <br />
---to remove a service remove the line or put something to change service name, other than symbols (# is fime) <br />
---to add put it in the proper format <br />
**Note:** Number meaning `0 -Not Installed/Skip`, `1 -Disable`, `2 -Manual`, `3 -Automatic`, `4 -Auto (Delayed)` <br />

**Q:** I have a suggestion for the script, how do i suggest it? <br />
**A:** Do a pull request with the change or submit it as an issue with the suggestion. <br />

**Q:** How long are you going to maintain the script? <br />
**A:** No Clue.

**Q:** When do you update the services file (BlackViper.csv)? <br />
**A:** When Black Viper tells me a change, I see an update on his site, or someone tells me there is an update.
