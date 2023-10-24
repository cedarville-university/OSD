# Define an array of package names for the applications you want to remove
$packageNames = @(
    "Microsoft.549981C3F5F10",
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.GamingApp",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.WindowsCommunicationsApps",
    "Microsoft.GetHelp",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.People",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo"
)

$teamsrunning = Get-Process -Name "msteams" -ErrorAction SilentlyContinue

if ($teamsrunning) {
    Get-Process -Name "msteams" | Stop-Process -Force
}

# Loop through the array and remove the specified applications
foreach ($packageName in $packageNames) {
    if (Get-AppxPackage -Name $packageName -AllUsers) {
        Get-AppxPackage -Name $packageName -AllUsers | Remove-AppxPackage -AllUsers
        Write-Host "Application $packageName has been removed."
    } else {
        Write-Host "Application $packageName is not installed."
    }
}
