# Quick runner for Windows PowerShell
# Usage: right-click and Run with PowerShell, or from PowerShell: .\run_project.ps1

Push-Location -Path "${PWD}"

Write-Host "Running flutter pub get..."
flutter pub get

Write-Host "Running flutter analyze..."
flutter analyze

Write-Host "Done. Next: run the app with 'flutter run' on a connected device or emulator." 

Pop-Location
