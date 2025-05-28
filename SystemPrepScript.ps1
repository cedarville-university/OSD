#Creates necessary folders on the system

New-Item -ItemType Directory -Path C:\Docs -Force
New-Item -ItemType Directory -Path c:\Temp -Force
New-Item -ItemType Directory -Path C:\Windows\System32\icons -force

# Get the ChassisTypes information
$chassisTypes = (Get-CimInstance -ClassName win32_computersystem).PCSystemType

# Check the ChassisTypes for specific values indicating system type
if ($chassisTypes -eq 2) {
    Write-Host "The system is a laptop."
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/cedarville-university/OSD/main/20250527-universityBackground.jpg -OutFile c:\temp\universityBackground.jpg
}  else {
    Write-Host "The system type is Desktop or VM."
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/cedarville-university/OSD/main/20250527-universityBackground.jpg -OutFile c:\temp\universityBackground.jpg 
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


#Prevent automatic device encryption during OOBE
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker" -Force
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\BitLocker" -Name "PreventDeviceEncryption" -PropertyType DWORD -Value 1 -Force

#Add Registry setting to RunOnce that will start app deployment after intital log in
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce" -Name "RunPushLaunchTask" -Value "powershell.exe -NoProfile -Command `"Get-ScheduledTask | ? {`$_.TaskName -eq 'PushLaunch'} | Start-ScheduledTask`""
