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

Copy-Item -Path "X:\OSDCloud\Config\RegScripts\AutopilotEnrollment.ps1" -Destination "c:\OSDCloud\Temp\" -Force
Copy-Item -Path "X:\OSDCloud\Config\Scripts\Copy-Unattendxml1.ps1" -Destination "C:\OSDCloud\Temp" -Force
& "C:\OSDCloud\Temp\Create-UnattendXML1.ps1"

pause

#================================================
#  [PostOS] OOBEDeploy Configuration
#================================================
Write-Host -ForegroundColor Green "Create C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json"
$OOBEDeployJson = @'
{
    "Autopilot":  {
                      "IsPresent":  false
                  },
    "UpdateDrivers":  {
                          "IsPresent":  true
                      },
    "UpdateWindows":  {
                          "IsPresent":  true
                      }
}
'@
If (!(Test-Path "C:\ProgramData\OSDeploy")) {
    New-Item "C:\ProgramData\OSDeploy" -ItemType Directory -Force | Out-Null
}
$OOBEDeployJson | Out-File -FilePath "C:\ProgramData\OSDeploy\OSDeploy.OOBEDeploy.json" -Encoding ascii -Force

#================================================
#  [PostOS] AutopilotOOBE CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Create C:\Windows\System32\Autopilot.cmd"
$AutopilotCMD = @'
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force
Set Path = %PATH%;C:\Program Files\WindowsPowerShell\Scripts
Start /Wait PowerShell -NoL -C Install-Module OSD -Force -Verbose -SkipPublisherCheck
Start /Wait PowerShell -NoL -C Install-Module AutoPilotOOBE -Force -Verbose -SkipPublisherCheck
Start /Wait PowerShell -NoL -C Start-OOBEDeploy
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
C:\Windows\System32\Autopilot.cmd
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
Write-Host  -ForegroundColor Green "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
pause
wpeutil reboot
