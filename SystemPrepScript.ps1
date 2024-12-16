#Creates necessary folders on the system

New-Item -ItemType Directory -Path C:\Docs -Force
New-Item -ItemType Directory -Path c:\Temp -Force
New-Item -ItemType Directory -Path C:\Windows\System32\icons -force

# Get the ChassisTypes information
$chassisTypes = (Get-CimInstance -ClassName win32_computersystem).PCSystemType

# Check the ChassisTypes for specific values indicating system type
if ($chassisTypes -eq 2) {
    Write-Host "The system is a laptop."
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/cedarville-university/OSD/main/universityBackground_2017-11-17_PC_1366x768.jpg -OutFile c:\temp\universityBackground.jpg
}  else {
    Write-Host "The system type is Desktop or VM."
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/cedarville-university/OSD/main/universityBackground_2017-11-17_PC_1920x1080.jpg -OutFile c:\temp\universityBackground.jpg 
}

#Copy background file to required folder and then delete downloaded file from Github.
Copy-Item -Path "c:\temp\universityBackground.jpg" -Destination "C:\Windows\System32\icons\" -Force
Remove-Item -Path "c:\temp\universityBackground.jpg" -Force

#Remove DevHome and Outlook Apps from the installation.
Remove-item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\DevHomeUpdate\" -Force -Recurse
Remove-item -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\Orchestrator\UScheduler_Oobe\OutlookUpdate\" -Force -Recurse

#Disable Quick Assist from installation
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\QuickAssist" -Force
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\QuickAssist" -Name "DisableQuickAssist" -PropertyType DWORD -Value 1 -Force
