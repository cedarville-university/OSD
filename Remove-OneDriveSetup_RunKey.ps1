#Create PSDrive for HKU
New-PSDrive -PSProvider Registry -Name HKUDefaultHive -Root HKEY_USERS

#Load Default User Hive
reg load "HKU\DefaultHive" "C:\Users\Default\NTUSER.DAT"

#Set OneDriveSetup Variable
$oneDriveSetup = Get-ItemProperty "HKUDefaultHive:\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Run" | select -ExpandProperty "OneDriveSetup"

#If Variable returns True, remove OneDriveSetup Value
If ($oneDriveSetup) { Remove-ItemProperty -Path "HKUDefaultHive:\DefaultHive\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDriveSetup"}

#Unload Hive
Reg Unload "HKU\DefaultHive\"

#Remove PSDrive HKUDefaultHive
Remove-PSDrive "HKUDefaultHive"

#Remove OneDrive Installation
Start-Process -FilePath "C:\Windows\System32\OneDriveSetup.exe" -ArgumentList '/uninstall' -Wait
