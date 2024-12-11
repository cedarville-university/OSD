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
Copy-Item X:\OSDCloud\Config\RegScripts\get-windowsautopilotinfocommunity.ps1 C:\Windows\Setup\scripts -Force
Copy-Item X:\OSDCloud\Config\Scripts\Create-UnattendXML.ps1 C:\OSDCloud\Temp -Force
& c:\OSDCloud\Temp\Create-UnattendXML.ps1
