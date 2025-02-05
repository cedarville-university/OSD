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
#   Restart-Computer
#=======================================================================
Write-Host  -ForegroundColor Green "Restarting in 20 seconds!"
Start-Sleep -Seconds 20
wpeutil reboot
