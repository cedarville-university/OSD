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

# Set Bios Settings for Dell Systems
if((Get-MyComputerManufacturer) -match "Dell Inc.") {
    Write-Host "Setting Dell Bios Settings"
    x:\osdcloud\Config\Dell\BiosSetting\Set-CUDellBiosSettings.ps1
}
# Set Bios Settings for Lenovo Systems
if((Get-MyComputerManufacturer) -match "LENOVO") {
    Write-Host "Setting Lenovo Bios Settings"
    x:\osdcloud\Config\Lenovo\BiosSetting\Set-LenovoBiosSettings.ps1
}

#=======================================================================
#   [OS] Params and Start-OSDCloud
#=======================================================================
$Params = @{
    OSVersion = "Windows 11"
    OSBuild = "23H2"
    OSEdition = "Education"
    OSLanguage = "en-us"
    OSActivation = "Volume"
    ZTI = $true
}
Start-OSDCloud @Params
#================================================
#  [PostOS] AutopilotOOBE CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Create C:\Windows\System32\Autopilot.cmd"
$AutopilotCMD = @'
PowerShell -NoL -Com Set-ExecutionPolicy RemoteSigned -Force
Set Path = %PATH%;C:\Program Files\WindowsPowerShell\Scripts
Start /Wait PowerShell -NoL -C Install-Module OSD -Force -Verbose -SkipPublisherCheck
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
wpeutil reboot


Start-OSDCloudGUI
