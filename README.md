[![Donate](https://img.shields.io/badge/Donate-Amazon-yellowgreen.svg?style=plastic)](https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/)
[![GitHub Release](https://img.shields.io/github/release/madbomb122/BlackViperScript.svg?style=plastic)](https://github.com/madbomb122/BlackViperScript/releases)
[![GitHub Release Date](https://img.shields.io/github/release-date/madbomb122/BlackViperScript.svg?style=plastic)](https://github.com/madbomb122/BlackViperScript/releases)
[![GitHub Issues](https://img.shields.io/github/issues/madbomb122/BlackViperScript.svg?style=plastic)](https://github.com/madbomb122/BlackViperScript/issues)
# 
To Download go to -> [Black Viper Script -Release](https://github.com/madbomb122/BlackViperScript/releases)<br/>

**Current Version** <br/>
**Script:** `5.0.7` (July 14, 2018) <br/>
**Service:** `4.0` (May 29, 2018) -April 2018 Update <br/>

# Description
This script lets you set Windows 10's services based on Black Viper's Service Configurations, your own Service Configuration (If in a proper format), a backup of your Service Configurations made by this script, or a Custom Configuration using the script. <br/>

Black Viper's Service Configurations from http://www.blackviper.com/

**Note: This Script is ment for Windows 10 Home x64 / Windows 10 Pro x64.. With Creator's Update or newer Installed**  <br/>

PS. Don't forget to check out my other Repo https://github.com/madbomb122/Win10Script  <br/>

PPS. My Thanks goes out to all that have helped in any way.

# Requirements (Make sure to LOOK at this)

|            | Recommended Requirements         | AT YOUR OWN RISK* (See Note Below) |
| :--------- | :--------------------------------| :--------------------------- |
|**OS**      | Windows 10                       |                              |
|**Bit**     | 64-bit (x64)                     | 32-bit (x86)                 |
|**Edition** | Pro or Home                      | All Others                   |
|**Build**   | Creator's Update                 | Pre-Creator's Update         |

<br/>

**_Need Files_** <br/>
[BlackViper-Win10.ps1](https://github.com/madbomb122/BlackViperScript/raw/master/BlackViper-Win10.ps1) (Script) -Size about `101.0 KB`<br/>
[BlackViper.csv](https://github.com/madbomb122/BlackViperScript/raw/master/BlackViper.csv) (Service Configurations) -Size about `6.84 KB` (Not the same as the one on BlackViper's Website)<br/>

**Recommended Files** <br/>
[Update.bat](https://github.com/madbomb122/BlackViperScript/raw/master/Update.bat) (Script will use to update script if available) -Size about `11.7 KB`<br/> 
[_Win10-BlackViper.bat](https://github.com/madbomb122/BlackViperScript/raw/master/_Win10-BlackViper.bat) (To run script easier) -Size about `5.49 KB`<br/> 
[README.md](https://github.com/madbomb122/BlackViperScript/raw/master/README.md) (This Readme) <br/>

**You can do a `save as` on the filenames above to save them to you computer, you cannot do a `save as` on github's file list**

**Note:**
**AT YOUR OWN RISK**<br/>
**1. Run the script on x86 (32-bit) ,But shows a warning**<br/>
**2. Skip the check for**<br/>
**---A. Home/Pro** *(`$Script:Edition_Check` variable in script or use `-sec` switch)*<br/>
**---B. Creator's Update** *(`$Script:Build_Check` variable in script or use `-sbc` switch)*<br/>

# How to Use/Run
Download/Save the release file in - [Black Viper Script -Release](https://github.com/madbomb122/BlackViperScript/releases)<br/>
  **Note 1: DO NOT RENAME THE FILES**<br/>
  **Note 2: HAVE THE FILES IN THE SAME DIRECTORY**<br/>
Next follow the **Basic Usage** or **Advanced Usage**

# Youtube Video
Someone found a Youtube video about my script on how to use it and I thought it might be useful. <br/>
[https://www.youtube.com/watch?v=AiL4E56t8YI](https://www.youtube.com/watch?v=AiL4E56t8YI) <br/>
Video brought to you by [Britec09](https://www.youtube.com/channel/UC_M-iWYpQbgo4rK1YfewI5w) <br/>

# Basic_Usage
Run the Script by bat file `_Win10-BlackViper.bat` (Recommended)<br/>
or<br/>
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File c:/BlackViper-Win10.ps1`<br/>
*For the above, Please note you need change the c:/ to the fullpath of your file*<br/>
Select desired Services Configuration<br/>
Select the options you want and then click run script<br/>

# Advanced_Usage
Use one of the following Methods you can 
1. Run script or bat file with one (or more) of the switches below
2. Edit the script (bottom of file) to change the values
3. Edit the bat file (top of file) to change the values to add the switch


|   Switch  | Description                                                                    | Notes                            |
| :-------- | :------------------------------------------------------------------------------| :------------------------------- |
| -atos     | Accepts the ToS                                                                |                                  |
| -auto     | Runs the script to be Automated.. Closes on User input, Errors, End of Script) | Implies `-atos`                  |
| -default  | Runs the script with Services to Default Configuration                         |   |
| -safe     | Runs the script with Services to Black Viper's Safe Configuration              |   |
| -tweaked  | Runs the script with Services to Black Viper's Tweaked Configuration           |   |
| -all      | Every windows services will change                                             |   |
| -min      | Just the services different from the default to safe/tweaked list              |   |
| -bscc     | Backup Current Service Configuration (CSV file)                   | Filename will be `COMPUTERNAME-Service-Backup.csv`   |
| -bscr     | Backup Current Service Configuration (REG file)                   | Filename will be `COMPUTERNAME-Service-Backup.reg`   |
| -bscB     | Backup Current Service Configuration (CSV and REG file)      | Filename will be `COMPUTERNAME-Service-Backup.FILETYPE`   |
| -lcsc File.csv | Loads Custom Service Configuration                             | `File.csv` Name of backup/custom file |
| -sec      | Skips Edition Check (Home/Pro), Sets edition as Pro                            | **USE AT YOUR OWN RISK**         |
| -secp     | Skips Edition Check (Home/Pro), Sets edition as Pro                            | **USE AT YOUR OWN RISK**         |
| -sech     | Skips Edition Check (Home/Pro), Sets edition as Home                           | **USE AT YOUR OWN RISK**         |
| -sbc      | Skips Build Check (Creator's Update)                                           | **USE AT YOUR OWN RISK**         |
| -sxb      | Skips Change to All Xbox Services                                              | It keeps current setting         |
| -sic      | Skips Internet Check (If checking for update)                                  | Tests by pinging github.com      |
| -usc      | Checks for Update to Script file before running                                | Auto downloads and runs if found |
| -use      | Checks for Update to Service file before running                               | Auto downloads and uses if found |
| -snis     | Shows not installed services (that can be changed)                             |  |
| -sss      | Show Skipped Services                                                         |   |
| -diag     | Shows some diagnostic information on error messages                            | **Stops automation** |
| -log      | Makes a log file (Logs Notices, Errors, & Services changed)                    | Log file `Script.log` (default) |
| -baf      | File of all the services before and after the script                 | `Services-Before.log` and `Services-After.log`    |
| -dry      | Runs script and shows what will be changed if ran normaly                     | **No Services are changes** |
| -devl     | Makes a log file with various Diagnostic information                          | **No Services are changes** |
| -help     | Lists of all the switches                                                     | Alt `-h` |


Switch Examples: <br/>
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -lcsc MyComp-Service-Backup.csv` <br/>
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -Set Default` <br/>
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -auto -use -tweaked -sec` <br/>
`_Win10-BlackViper.bat -Set Default` <br/>
`_Win10-BlackViper.bat -auto -use -tweaked -sec` <br/>
******
# Update.Bat
This file is EXACTLY the same as the one in my other Repo

This file will <br/>
1. Allow you to download my Black Viper Script or my Win 10 Script and the needed files (if any). <br/>
2. The script will use to Download updates (to replace the old file, instead of creating a new file, so you dont have to rename the file or edit the bat file). (If this script is present) <br/>

|   Switch  | Description                                                                    |
| :-------- | :------------------------------------------------------------------------------|
| -Help     | Shows the list of switches                                                     |
| -BV       | Downloads My Black Viper Script                                                |
| -W10      | Downloads My Windows 10 Script                                                 |
| -Both     | Downloads My Black Viper Script & My Windows 10 Script                         |
| -Test     | Downloads The Test Version of the Script                                       |
| -Run      | Run the Script after Downloading (Does not work with -both)                    |
| -Bat      | Download the bat file to run script easier                                     |

******

# FAQ
**Q:** The script file looks all messy in notepad, How do i view it? <br/>
**A:** Try using wordpad or what I recommend, Notepad++ [https://notepad-plus-plus.org/](https://notepad-plus-plus.org/) 

**Q:** Do you accept any donations? <br/>
**A:** If you would like to donate to me Please pick an item/giftcard from my amazon wishlist or Contact me about donating, Thanks. BTW The giftcard amount can be changed to a min of $1. <br/>
**Wishlist:** [https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/](https://www.amazon.com/gp/registry/wishlist/YBAYWBJES5DE/)<br/>

**Q:** Are You or Black Viper the developer? <br/>
**A:** [Black Viper](http://www.blackviper.com/) is the creator of the service configuration. I am the developer of the script, the blackviper.csv file uses black viper's configuration. 

**Q:** I have a suggestion/Issue for the script, how do I suggest it? <br/>
**A:** Do a pull request with the change or submit it as an issue with the suggestion. <br/>

**Q:** How can I contact you? <br/>
**A:** 1. You can also PM me on reddit /u/madbomb122 [https://www.reddit.com/user/madbomb122](https://www.reddit.com/user/madbomb122) <br/>
2. You can email me @ madbomb122@gmail.com. <br/>
**Note** Before contacting me, please make sure you have ALL the needed files and the size is right (Look above under requirements). 

**Q:** The Run button is disabled what do i do? <br/>
**A:** Look in the script option and skip the appropriate check (Build for Build, Edition for Edition).

**Q:** The script wont run, can you help me? <br/>
**A:** Yes, but first if you are using automation.. turn off automation and see if it gives and error that you can correct.

**Q:** Please E-Mail me if you are getting an Edition error when running Home/Pro? <br/>
**A:** E-Mail me what your edition is and what edition it says you are using, so I can add it to the list, Until then use -secp (for Pro) or -sech (for Home), Thanks.

**Q:** The script window closes or gives an error saying script is blocked, what do i do? <br/>
**A:** By default windows blocks ps1 scripts, you can use one of the following <br/>
         1. Use the bat file to run the script (recommended) <br/>
         2. On an admin powershell console `Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted` <br/>	 

**Q:** Who do I contact about the Service Configurations or an issue with the configuration? <br/>
**A:** Any "technical" issues (or why something is set one way or another) can be directed to Black Viper himself.

**Q:** Why does you script not change the service *BLAH*? <br/>
**A:** You didnt select the All option, it's not a default windows service, cant be changed, or some other good reason.

**Q:** I have an issue with the script, what do I do? <br/>
**A:** Post it as an issue using github's issues tab up top.

**Q:** Can I run the script safely? <br/>
**A:** Yes/No, it's safe to change the services back to default. Using the Safe or Tweaked option may cause problems for a program(s) that is depended on one of those services.

**Q:** Can I run the script repeatedly? <br/>
**A:** Yes, with same or different settings.

**Q:** I've run the script and it did *BLAH*, can I undo it? <br/>
**A:** Yes, run the script again and select again or load the backup configuration (if you made one). <br/>

**Q:** Can I use the script or modify it for my / my company's needs? <br/>
**A:** Sure. Just don't forget to include copyright notice as per the license requirements, and leave any Copyright in script too, if you make money from using it please consider a donation as thanks.

**Q:** The script messed up my computer because it did *BLAH*. <br/>
**A:** Any problems you have/had is your own problem.

**Q:** Are you going to add support for other editions of Windows 10 other than Pro or Home? <br/>
**A:** Sorry, I only support the windows 10 configuration listed on Black Viper's website, you can still use it on other edition but any problems you have are your own. <br/>

**Q:** Are you going to add support for builds before the "Creator's Update"? <br/>
**A:** Sorry, since I dont have Black Viper's configuration from before the "Creator's Update" I can't add it. You can use the configuration for Creator's Update, but at your own risk of possible issues. <br/>
**Note:** If you have Black Viper's configuration for pre-Creator's update please contact me, thanks.

**Q:** Will you make a script for any windows before windows 10? <br/>
**A:** No. <br/>

**Q:** What do the letters mean in the release tab after the version number? <br/>
**A:** The letter indicates that something other than the script was updated when the script version hasn't changed.. `B = Bat file`, `S = Service file`, `U = Update Bat file`, `M = Misc or Multiple Changes`  <br/>

**Q:** Can I download the csv file from Black Viper's website and use that? <br/>
**A:** No, my file is not the same. <br/>

**Q:** Can I add a service to be changed or stop one from changing? <br/>
**A:** Yes, to add/remove edit the file `BlackViper.csv` or use the gui and uncheck the services you dont want changed <br/>
---to remove a service remove the line or put something to change service name, other than symbols (# is fine) <br/>
---to add put it in the proper format <br/>
**Note:** Number meaning `0 -Not Installed/Skip`, `1 -Disable`, `2 -Manual`, `3 -Automatic`, `4 -Auto (Delayed)` <br/>

**Q:** How long are you going to maintain the script? <br/>
**A:** No Clue.

**Q:** When do you update the services file 'BlackViper.csv'? <br/>
**A:** When I get told or see there has been an update to the services. Some updates may take a while if changes in the script it required, like from Window's Big Update Patches.
