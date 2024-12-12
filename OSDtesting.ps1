#================================================
#   [PreOS] Update Module 
#================================================
if ((Get-MyComputerModel) -match 'Virtual') {
    Write-Host  -ForegroundColor Green "Setting Display Resolution to 1600x"
    Set-DisRes 1600
}



Write-Host -ForegroundColor Green "Updating OSD PowerShell Module"
Install-Module OSD -Force -SkipPublisherCheck

Write-Host  -ForegroundColor Green "Importing OSD PowerShell Module"
Import-Module OSD -Force   

#=======================================================================
#   [OS] Params and Start-OSDCloud
#=======================================================================
$Params = @{
    OSVersion = "Windows 11"
    OSBuild = "24H2"
    OSEdition = "Education"
    OSLanguage = "en-us"
    OSActivation = "Volume"
    ZTI = $true
}
Start-OSDCloud @Params

Copy-Item X:\OSDCloud\Config\RegScripts\Autopilot.ps1 C:\Windows\Setup\scripts -Force
Copy-Item X:\OSDCloud\Config\Scripts\Create-UnattendXML.ps1 C:\OSDCloud\Temp -Force
& c:\OSDCloud\Temp\Create-UnattendXML.ps1

#================================================
#  [PostOS] AutopilotOOBE CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Create C:\Windows\System32\Autopilot.cmd"
$AutopilotCMD = @'
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force
Set Path = %PATH%;C:\Program Files\WindowsPowerShell\Scripts
Start /Wait PowerShell -NoL -C Install-Module OSD -Force -Verbose -SkipPublisherCheck
#Start /Wait PowerShell -NoL -C Start-OOBEDeploy
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/cedarville-university/OSD/main/SystemPrepScript.ps1
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/cedarville-university/OSD/main/Remove-Appx-AllUsers2.ps1
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/cedarville-university/OSD/main/Remove-OneDriveSetup_RunKey.ps1
REM Start /Wait PowerShell -NoL -C Restart-Computer -Force
'@
$AutopilotCMD | Out-File -FilePath 'C:\Windows\System32\Autopilot.cmd' -Encoding ascii -Force

#================================================
#  [PostOS] SetupComplete CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Create C:\Windows\Setup\Scripts\SetupComplete.cmd"
$SetupCompleteCMD = @'
RD C:\OSDCloud /S /Q
RD C:\Drivers /S /Q
DEL c:\windows\setup\scripts\autopilot.ps1 /Q
C:\Windows\System32\Autopilot.cmd
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
#Write-Host  -ForegroundColor Green "Restarting in 20 seconds!"
#Start-Sleep -Seconds 20
#wpeutil reboot
