<#
.SYNOPSIS
Script to download slides and audio/video of Build 2016 presentations.
.DESCRIPTION
Downloads slides and audio/video from all presentations at Build 2016. User defines target path and video quality.
.PARAMETER SaveToDirectory    
Path to save slides and videos, preferably short to avoid path length issues. Defaults to C:\Build16
.PARAMETER VideoQuality
Quality of videos (.mp4) to download: high, medium, low, or audio only (.mp3)
.EXAMPLE
PS C:\> .\Download-Build2016Artifacts.ps1 -SaveToDirectory "F:\Build16" -VideoQuality -High
#>
    
Param(
    [Parameter(Position=0,Mandatory=$False)]   
    [string]$SaveToDirectory = "C:\Build16",
    [Parameter(Position=1,Mandatory=$False)]
    [ValidateSet("High","Medium","Low","AudioOnly")]
    [string]$VideoQuality = "High" 
)

[Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath 
$webClient = (new-object net.webclient)

# Grab the URLs for the Build 2016 Videos and Slides
$slideUrl = ([xml]$webClient.downloadstring("http://s.ch9.ms/Events/Build/2016/rss/slides"))
$videoUrlHighQuality = ([xml]$webClient.downloadstring("http://s.ch9.ms/Events/Build/2016/rss/mp4high"))  
$videoUrlMediumQuality = ([xml]$webClient.downloadstring("http://s.ch9.ms/Events/Build/2016/rss/mp4med"))
$videoUrlLowQuality = ([xml]$webClient.downloadstring("http://s.ch9.ms/Events/Build/2016/rss/mp4")) 
$videoUrlAudioOnly = ([xml]$webClient.downloadstring("http://s.ch9.ms/Events/Build/2016/rss/mp3")) 

#Determine the video quality the user selected and set that url as the one to use.
Switch($VideoQuality) {
    "High" {$VideoUrl = $videoUrlHighQuality}
    "Medium" {$VideoUrl = $videoUrlMediumQuality}
    "Low" {$VideoUrl = $videoUrlLowQuality}
    "AudioOnly" {$VideoUrl = $videoUrlAudioOnly}
}

#Preferably enter something not too long to not have path length problems!
$downloadlocation = $SaveToDirectory

if (-not (Test-Path $downloadlocation)) { 
	Write-Host "Folder $fpath dosen't exist. Creating it..."  
	New-Item $downloadlocation -type directory 
}

Set-Location $downloadlocation

#Download all the slides	
try { 

    $slideUrl.rss.channel.item | foreach{   
        $code = $_.comments.split("/") | select -last 1	   
        
        # Grab the URL for the PPTX file
        $urlpptx = New-Object System.Uri($_.enclosure.url)  
        $filepptx = $code + "-" + $_.creator + " - " + $_.title.Replace(":", "-").Replace("?", "").Replace("/", "-").Replace("<", "").Replace("|", "").Replace('"',"").Replace("*","")
        $filepptx = $filepptx.substring(0, [System.Math]::Min(120, $filepptx.Length))
        $filepptx = $filepptx.trim()
        $filepptx = $filepptx + ".pptx" 
        if ($code -ne "")
        {
            $folder = $code + " - " + $_.title.Replace(":", "-").Replace("?", "").Replace("/", "-").Replace("<", "").Replace("|", "").Replace('"',"").Replace("*","")
            $folder = $folder.substring(0, [System.Math]::Min(100, $folder.Length))
            $folder = $folder.trim()
        }
        else
        {
            $folder = "NoCodeSessions"
        }
        
        if (-not (Test-Path $folder)) { 
            Write-Host "Folder $folder dosen't exist. Creating it..."  
            New-Item $folder -type directory 
        }

        # Make sure the PowerPoint file doesn't already exist
        if (!(test-path "$downloadlocation\$folder\$filepptx"))     
        { 	
            # Echo out the  file that's being downloaded
            $filepptx
            $wc = (New-Object System.Net.WebClient)  

            # Download the MP4 file
            $wc.DownloadFile($urlpptx, "$downloadlocation\$filepptx")
            mv $filepptx $folder 
        }
        }
}
catch
{
    Write-host "Slides are not yet up. Run this script every day to get the latest updates"
}

# Download all the videos at the selected quality level.
# Walk through each item in the feed 
    $videoUrl.rss.channel.item | foreach{   
	    $code = $_.comments.split("/") | select -last 1	   
	
	    # Grab the URL for the MP4 file
	    $url = New-Object System.Uri($_.enclosure.url)  
	
	    # Create the local file name for the MP4 download
	    $file = $code + "-" + $_.creator + "-" + $_.title.Replace(":", "-").Replace("?", "").Replace("/", "-").Replace("<", "").Replace("|", "").Replace('"',"").Replace("*","")
	    $file = $file.substring(0, [System.Math]::Min(120, $file.Length))
	    $file = $file.trim()

        if ($VideoQuality -eq "AudioOnly")
        {
	        $file = $file + ".mp3"  
        }
        else
        {
            $file = $file + ".mp4" 
        }
	
	    if ($code -ne "")
	    {
		     $folder = $code + " - " + $_.title.Replace(":", "-").Replace("?", "").Replace("/", "-").Replace("<", "").Replace("|", "").Replace('"',"").Replace("*","")
		     $folder = $folder.substring(0, [System.Math]::Min(100, $folder.Length))
		     $folder = $folder.trim()
	    }
	    else
	    {
		    $folder = "NoCodeSessions"
	    }
	
	    if (-not (Test-Path $folder)) { 
		    Write-Host "Folder $folder) dosen't exist. Creating it..."  
		    New-Item $folder -type directory 
	    }	
		
	    # Make sure the MP4 file doesn't already exist
	    if (!(test-path "$folder\$file"))     
	    { 	
		    # Echo out the  file that's being downloaded
		    $file
		    $wc = (New-Object System.Net.WebClient)  

		    # Download the MP4 file
		    $wc.DownloadFile($url, "$downloadlocation\$file")
		    mv $file $folder
	    }

    #text description from session
	    $OutFile = New-Item -type file "$($downloadlocation)\$($Folder)\$($Code.trim()).txt" -Force  
        $Category = "" ; $Content = ""
        $_.category | foreach {$Category += $_ + ","}
        $Content = $_.title.trim() + "`r`n" + $_.creator + "`r`n" + $_.summary.trim() + "`r`n" + "`r`n" + $Category.Substring(0,$Category.Length -1)
       add-content $OutFile $Content		
	}