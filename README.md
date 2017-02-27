## Description
Easy to use Script that can set windows 10 services based on Black Viper's Settings.  <br />
**Note: Script will ONLY work on windows 10 Home or Pro, All others will not let you run the script**

Black Viper's Windows 10 Services Settings  <br />
http://www.blackviper.com/service-configurations/black-vipers-windows-10-service-configurations/

# [](#header-1)Basic Usage
Run the Script <br />
Use the Menu <br />
Select what you want <br />
*1. Default <br />
2. Safe <br />
3. Tweaked <br />*

## [](#header-2)Advanced Usage
Use one of the following Methods 
(Bat file provided can run script, look in bat file for insructions)

Run script with changing Services to Default Settings (Only ones changed by Black viper's settings): <br />
   -Set 1 <br />
   -Set Default

Examples: <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -Set 1` <br />
or <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File Win10-Menu.ps1 -Set Default` <br />
******

Run script with changing Services to Black Viper's Safe Setting: <br />
   -Set 2 <br />
   -Set Safe

Examples: <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -Set 2` <br />
or <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File Win10-Menu.ps1 -Set Safe` <br />
******

Run script with changing Services to Black Viper's Tweaked Setting: <br />
   -Set 3 <br />
   -Set Tweaked

Examples: <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File BlackViper-Win10.ps1 -Set 3` <br />
or <br />
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File Win10-Menu.ps1 -Set Tweaked` <br />
******

## FAQ
**Q:** The script file looks all messy in notepad, How do i view it? <br />
**A:** Try using wordpad or what I recommend, Notepad++ https://notepad-plus-plus.org/

**Q:** Can I run the script safely? <br />
**A:** The script itself is safe, but changes to services may cause problems

**Q:** Can I run the script repeatedly? <br />
**A:** Yes, with same or different settings. (same setting will do nothing but do some display)

**Q:** Can I use the script or modify it for my / my company's needs? <br />
**A:** Sure. Just don't forget to include copyright notice as per the license requirements, and leave any Copyright in script too.

**Q:** I've run the script and it did *BLAH*, can I undo it? <br />
**A:** Yes, run the script again and select again. <br />

**Q:** The script messed up my computer. <br />
**A:** The script is as is, any problems you have/had is not my problem.

**Q:** How long are you going to maintain the script? <br />
**A:** No Clue, but will update service changes when i see any changes
