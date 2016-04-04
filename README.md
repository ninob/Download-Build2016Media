# Download-Build2016Media.ps1
PowerShell script to download Build 2016 videos and slides. 
This script:
* Downloads all the Microsoft Build 2016 Conference Sessions and Slides
* Allows the user to specify a target download directory and video quality
* Supports Get-Help (ex: _Get-Help .\Download-Build2016Artifacts.ps1 -Detailed_)
* Groups session items by folder 
* Makes sure no errors come up due to illegal file names
* If you stop the script and restart in the middle, it will start where it left off 

Based on a script by Vlad Cantrinescu.
https://gallery.technet.microsoft.com/office/Script-to-Build-Session-022a5422#content
