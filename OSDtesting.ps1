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

#================================================
#  [PostOS] AutopilotOOBE CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Create C:\Windows\System32\Autopilot.cmd"
$AutopilotCMD = @'
Start /wait Powershell -NoL -C Set-ExecutionPolicy RemoteSigned -Force
Start /wait Powershell -NoL -C [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set Path = %PATH%;C:\Program Files\WindowsPowerShell\Scripts
Start /wait Powershell -NoL -C Set-PSRepository -Name PSGallery -InstallationPolicy Trusted 
Start /Wait PowerShell -NoL -C Install-Module OSD -Force -Verbose -SkipPublisherCheck
Start /wait Powershell -Nol -C Start-WindowsUpdate
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/cedarville-university/OSD/main/SystemPrepScript.ps1
Start /Wait PowerShell -NoL -C Invoke-WebPSScript https://raw.githubusercontent.com/cedarville-university/OSD/main/Remove-OneDriveSetup_RunKey.ps1
REM Start /Wait PowerShell -NoL -C Restart-Computer -Force
'@
$AutopilotCMD | Out-File -FilePath 'C:\Windows\System32\Autopilot.cmd' -Encoding ascii -Force

#================================================
#  [PostOS] SetupComplete CMD Command Line
#================================================
Write-Host -ForegroundColor Green "Create C:\Windows\Setup\Scripts\SetupComplete.cmd"
$SetupCompleteCMD = @'
REM Set power plan to High Performance
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
REM Disable sleep mode
powercfg /change /standby-timeout-ac 0
powercfg /change /standby-timeout-dc 0
RD C:\OSDCloud /S /Q
RD C:\Drivers /S /Q
C:\Windows\System32\Autopilot.cmd
REM Restore default power schemes
powercfg /restoredefaultschemes
'@
$SetupCompleteCMD | Out-File -FilePath 'C:\Windows\Setup\Scripts\SetupComplete.cmd' -Encoding ascii -Force

#=======================================================================
#   Restart-Computer
#=======================================================================
Write-Host  -ForegroundColor Green "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
