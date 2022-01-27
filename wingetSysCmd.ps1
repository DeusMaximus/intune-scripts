$WingetCmd = Get-Command winget.exe -ErrorAction SilentlyContinue

if ($WingetCmd){
    $wingetsys = $WingetCmd.Source
}
elseif (Test-Path  "$env:ProgramW6432\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\AppInstallerCLI.exe"){
    $wingetsys = Resolve-Path  "$env:ProgramW6432\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\AppInstallerCLI.exe" | Select-Object -ExpandProperty Path
}
elseif (Test-Path  "$env:ProgramW6432\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"){
    $wingetsys = Resolve-Path  "$env:ProgramW6432\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe" | Select-Object -ExpandProperty Path
}
else{
    Write-Host "WinGet not Installed."
    return
}

& $wingetsys $args