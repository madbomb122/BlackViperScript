Will be adding a gitrelease to download all files to run script after the next update (v 4.0), when BlackViper releases the configuration for the upcoming windows 10 fall creator's update and when i have tested the script with the updates.

**Current Version** <br />
**Script:** `3.7.4` (October 4, 2017) <br />
**Service:** `2.0` (May 21, 2017) <br />

# Description
This script lets you set Windows 10's services based on Black Viper's Service Configurations, your own Service Configuration (If in a proper format), or a backup of your Service Configurations made by this script. <br />

Black Viper's Service Configurations from http://www.blackviper.com/

**Note 1: Script is ment for Windows 10 Home x64 / Windows 10 Pro x64.. With Creator's Update Installed**  <br />
**Note 2: If you are using a non english version of Windows and get a Build Check Error, please let me know**  <br />

PS. Don't forget to check out my other Repo https://github.com/madbomb122/Win10Script  <br />

PPS. My Thanks goes out to all that have helped in any way

# Requirements (Make sure to LOOK at this)

|            | Recommended Requirements         | AT YOURN OWN RISK* (See Note Bellow) |
| :--------- | :--------------------------------| :--------------------------- |
|**OS**      | Windows 10 x64                   | Windows 10 x32               |
|**Edition** | Pro or Home                      | All Others                   |
|**Build**   | Creator's Update                 | Pre-Creator's Update         |

<br />

**_Need Files_** <br />
[BlackViper-Win10.ps1](https://github.com/madbomb122/BlackViperScript/raw/master/BlackViper-Win10.ps1) (Script) -Size about `65.0 KB`<br />
[BlackViper.csv](https://github.com/madbomb122/BlackViperScript/raw/master/BlackViper.csv) (Service Configurations) -Size about `6.54 KB` (Not the same as the one on BlackViper's Website)<br />

**Recommended Files** <br />
[Update.bat](https://github.com/madbomb122/BlackViperScript/raw/master/Update.bat) (Script will use to update script if available) -Size about `12.4 KB`<br /> 
[_Win10-BlackViper.bat](https://github.com/madbomb122/BlackViperScript/raw/master/_Win10-BlackViper.bat) (To run script easyer) -Size about `4.85 KB`<br /> 
[README.md](https://github.com/madbomb122/BlackViperScript/raw/master/README.md) (This Readme) <br />

**You can do a `save as` on the filenames above to save them to you computer, you cannot do a `save as` on github's file list**

**Note:**
**AT YOUR OWN RISK**<br />
**1. Run the script on x32 w/o changing settings (But shows a warning)**<br />
**2. Skip the check for**<br />
**---A. Home/Pro** *(`$Script:Edition_Check` variable in script or use `-sec` switch)*<br />
**---B. Creator's Update** *(`$Script:Build_Check` variable in script or use `-sbc` switch)*<br />

# How to Use/Run
Download/Save the following files<br />
Script File: [BlackViper-Win10.ps1](https://github.com/madbomb122/BlackViperScript/raw/master/BlackViper-Win10.ps1) -Need<br />
Service Config File: [BlackViper.csv](https://github.com/madbomb122/BlackViperScript/raw/master/BlackViper.csv) -Need (Not the same as the one on BlackViper's Website)<br />
Bat File: [_Win10-BlackViper.bat](https://github.com/madbomb122/BlackViperScript/raw/master/_Win10-BlackViper.bat) -Recommended<br />
Bat File: [Update.bat](https://github.com/madbomb122/BlackViperScript/raw/master/Update.bat) (Script will use to update script if available) -Recommended<br />
  **Note 1: DO NOT RENAME THE FILES**<br />
  **Note 2: HAVE THE FILES IN THE SAME DIRECTORY**<br />
Next follow the **Basic Usage** or **Advanced Usage**

**You can do a `save as` on the filenames above to save them to you computer, you cannot do a `save as` on github's file list**

# Basic_Usage
Run the Script by bat file `_Win10-BlackViper.bat` (Recommended)<br />
or<br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File c:/BlackViper-Win10.ps1`<br />
*For the above, Please note you need change the c:/ to the fullpath of your file*<br />
Select desired Services Configuration<br />
Select the options you want and then click run script<br />

# Advanced_Usage
Use one of the following Methods you can 
1. Run script or bat file with one (or more) of the switches bellow
2. Edit the script (bottom of file) to change the values
3. Edit the bat file (top of file) to change the values to add the switch


|   Switch  | Description                                                                    | Notes                            |
| :-------- | :------------------------------------------------------------------------------| :------------------------------- |
| -atos     | Accepts the ToS                                                                |                                  |
| -auto     | Runs the script to be Automated.. Closes on User input, Errors, End of Script) | Implies `-atos`                |
| -default  | Runs the script with Services to Default Configuration                         |   |
| -safe     | Runs the script with Services to Black Viper's Safe Configuration              |   |
| -tweaked  | Runs the script with Services to Black Viper's Tweaked Configuration           |   |
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
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -auto -use -tweaked -sec` <br />
`_Win10-BlackViper.bat -Set Default` <br />
`_Win10-BlackViper.bat -auto -use -tweaked -sec` <br />
******
# Update.Bat
This file is EXACTLY the same as the one in my other Repo

This file will <br />
1. Allow you to download my Black Viper Script or my Win 10 Script and the needed files (if any). <br />
2. The script will use to Download updates (to replace the old file, instead of creating a new file, so you dont have to rename the file or edit the bat file). (If this script is present) <br />

|   Switch  | Description                                                                    |
| :-------- | :------------------------------------------------------------------------------|
| -Help     | Shows the list of switches                                                     |
| -BV       | Downloads My Black Viper Script                                                |
| -W10      | Downloads My Windows 10 Script                                                 |
| -Both     | Downloads My Black Viper Script & My Windows 10 Script                         |
| -Test     | Downloads The Test Version of the Script                                       |
| -Run      | Run the Script after Downloading (Does ntow work with -both)                   |
| -Bat      | Download the bat file to run script easyer                                     |

******

# FAQ

**Q:** The script file looks all messy in notepad, How do i view it? <br />
**A:** Try using wordpad or what I recommend, Notepad++ https://notepad-plus-plus.org/

**Q:** Do you accept any donations? <br />
**A:** If you would like to donate to me Please Contact me about donating or pick an item from my amazon wishlist. Please also consider donating to Black Viper too. Thanks <br />
**Wishlist:** https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/ <br />
**NOTE:** http://www.blackviper.com/support-bv/  <br />

**Q:** How can I contact you? <br />
**A:** You can email me @ madbomb122@gmail.com, if it's an issue please post under issue. Before contacting me make sure you have ALL the needed files and the size is right (Look above under requirements)

**Q:** The Run button is disabled what do i do? <br />
**A:** Look in the script option and skip the appropriate check (Build for Build, Edition for Edition).

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
