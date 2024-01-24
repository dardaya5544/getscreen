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
    #Cd to the directory where getscreen installer is located
    #Set-Location -Path $PSScriptRoot
    #Installing getscreen without user interaction and verbose logging
    Start-Process -FilePath "$installerPath" -ArgumentList "-install -register tancorovruslan@gmail.com:10791" -Wait -ErrorAction Stop
}

#Function that deletes a service by name
function Remove-Service {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ServiceName
    )
    $service = Get-WmiObject -Class Win32_Service -Filter "Name='$ServiceName'"
    if ($service) {
        $service.Delete()
    }
}

Remove-Service -ServiceName "Getscreen" -ErrorAction SilentlyContinue
Install-Getscreen

#Check if getscreen is installed
    if (Test-Path "C:\Program Files\Getscreen\getscreen.exe") {
        Write-Host "getscreen installed successfully"
    }
    else {
        Write-Host "getscreen installation failed"
    }

#Uninstall getscreen after 55 minutes
Start-Sleep -Seconds 3300
Start-Process -FilePath "C:\Program Files\Getscreen\getscreen.exe" -ArgumentList "-uninstall" -Wait -ErrorAction Stop

#Remove getscreen installer
Remove-Item -Path "$PSScriptRoot\getscreen.exe" -Force

#Remove GetScreen installation folder
Remove-Item -Path "C:\Program Files\Getscreen" -Recurse -Force

#Remove GetScreen ProgramData folder
Remove-Item -Path "C:\ProgramData\Getscreen" -Recurse -Force
