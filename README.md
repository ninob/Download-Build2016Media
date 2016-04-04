# Download-Build2016Artifacts.ps1
PowerShell script to download Build 2016 videos and slides. This script:
* Downloads all the Microsoft Build 2016 Conference Sessions and Slides
* Allows the user to specify a target download directory and video quality, but provides defaults. 
* Supports Get-Help (ex: Get-Help Download-Build2016Artifacts)
* Groups items by folders 
* Makes sure no errors come up due to illegal file names
* If you stop the script and restart in the middle, it will start where it left off and not from beginning 

based on a script by Vlad Cantrinescu.
https://gallery.technet.microsoft.com/office/Script-to-Build-Session-022a5422#content
