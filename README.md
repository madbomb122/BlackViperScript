## Description
Easy to use Script that can set Windows 10 services based on Black Viper's Service Configurations.  <br />

Black Viper's Service Configurations from http://www.blackviper.com/

**Note: Script is ment for Windows 10 Home x64 / Windows 10 Pro x64.. With Creator's Update Installed**  <br />

**Note: By default script checks for an update to the services file and will download if found**  <br />

**AT YOUR OWN RISK YOU CAN**  <br />
**1. Change variable at bottom of script to skip the check for Home/Pro, and/or Creator's Update**  <br />
**2. Still run the script on x32 w/o changing settings (But shows a warning)**  <br />

# [](#header-1)Basic Usage
Run the Script <br />
Use the Menu <br />
Select what you want <br />
*1. Default <br />
2. Safe <br />
3. Tweaked <br />*

## [](#header-2)Advanced Usage
Use one of the following Methods or use the at Bat file provided <br />
(Bat file provided can run script, look in bat file for insructions)

Run script with changing Services to Default Settings (Only ones changed by Black viper's settings): <br />
   -Set 1 <br />
   -Set Default

Examples: <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -Set 1` <br />
or <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -Set Default` <br />
******

Run script with changing Services to Black Viper's Safe Setting: <br />
   -Set 2 <br />
   -Set Safe

Examples: <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -Set 2` <br />
or <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -Set Safe` <br />
******

Run script with changing Services to Black Viper's Tweaked Setting: <br />
   -Set 3 <br />
   -Set Tweaked

Examples: <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -Set 3` <br />
or <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -Set Tweaked` <br />
******

## FAQ
**Q:** The script file looks all messy in notepad, How do i view it? <br />
**A:** Try using wordpad or what I recommend, Notepad++ https://notepad-plus-plus.org/

**Q:** Who do I contact about the Service Configurations or an issue with the configuration? <br />
**A:** Any "technical" issues (or why something is set one way or another) can be directed to Black Viper himself.

**Q:** I have an issue with the script, what do I do? <br />
**A:** Post it as an issue using github's issues tab up top.

**Q:** Can I run the script safely? <br />
**A:** The script itself is safe, but changes to services may cause problems.

**Q:** Can I run the script repeatedly? <br />
**A:** Yes, with same or different settings.

**Q:** Can I use the script or modify it for my / my company's needs? <br />
**A:** Sure. Just don't forget to include copyright notice as per the license requirements, and leave any Copyright in script too.

**Q:** I've run the script and it did *BLAH*, can I undo it? <br />
**A:** Yes, run the script again and select again. <br />

**Q:** The script messed up my computer. <br />
**A:** The script is as is, any problems you have/had is your own problem.

**Q:** Are you going to add support for other version of Windows 10 other than pro or home? <br />
**A:** Sorry, I only support the windows 10 configuration listed on Black Viper's website. <br />

**Q:** Are you going to add support for builds before the "Creator's Update"? <br />
**A:** Sorry, since I dont have the configuration from before the "Creator's Update" I can't add it. <br />
**Note:** If you have the configuration please leave a comment with a way to contact you.

**Q:** Will you make a script for any windows before windows 10? <br />
**A:** Nope. <br />

**Q:** Can I add a service to be changed or stop one from changing? <br />
**A:** Yes, edit the CSV file that is imported and put it in the proper format <br />
**Note:** Number meaning 0 -Not installed, 1 -Disable, 2 -Manual, 3 -Auto Normal, 4 -Auto Delay <br />

**Q:** How long are you going to maintain the script? <br />
**A:** No Clue, but will update service changes when I see any changes or get notified of any changes.
