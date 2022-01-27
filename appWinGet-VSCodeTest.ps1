# Application Template 1.0

# Remember to do the following before running this script:
# Install-Module -Name "IntuneWin32App"
# Connect-MSIntuneGraph -TenantID "domain.onmicrosoft.com"

# Place all files in C:\Intune.
# Create a Source\Application\ folder for each app, an Output\ folder for the output, and an Icons\ folder for the icons.

# Source Details Details
$SourceFolder = "C:\Intune\Source\WinGet-SysContext" # This is the root folder where the application exists
$OutputFolder = "C:\Intune\Output" # This is the folder where the packaged .intunewin file will be created in

# Application Information
$appFile = "wingetSysCmd.ps1"
$appVersion = "Latest"
$appPublisher = "Microsoft Corporation"
$appDescription = "Visual Studio Code is a source-code editor made by Microsoft for Windows, Linux and macOS. Features include support for debugging, syntax highlighting, intelligent code completion, snippets, code refactoring, and embedded Git."
$appFeatured = $false # Only TRUE or FALSE here
#$appCategory = "Business" - Category not supported in current version of IntuneWin32App module. Set this in the portal instead.
$appInfoURL = "https://code.visualstudio.com/"
$appPrivacyURL = "https://go.microsoft.com/fwlink/?LinkId=521839" 
$appDeveloper = $appPublisher # Change if the developer isn't the publisher
$appOwner = "Myriad Services" # Who is responsible for this application?
$appNotes = "Uses WinGet" # Portal notes for application. Not end user facing.
$appWinGetID = "Microsoft.VisualStudioCode"

# Display name for application
$DisplayName = "Visual Studio Code"
#$DisplayName = "Application Name" + " " + $appVersion

# Create .intunewin package file
$IntuneWinFile = New-IntuneWin32AppPackage -SourceFolder $SourceFolder -SetupFile $appFile -OutputFolder $OutputFolder -Verbose 

# Create detection rule using file detection.
$DetectionRule = New-IntuneWin32AppDetectionRuleFile -Existence -Path "%LOCALAPPDATA%\Programs\Microsoft VS Code\" -FileOrFolder Code.exe -DetectionType exists

# Create custom requirement rule - WinGet scripts require version 1809 or above.
$RequirementRule = New-IntuneWin32AppRequirementRule -Architecture All -MinimumSupportedOperatingSystem 1809

# Convert image file to icon
# I recommend searching Google Image Search for "application icon 256x256" if you don't have an icon available.
$ImageFile = "C:\Intune\Icons\vscode.png"
$appIcon = New-IntuneWin32AppIcon -FilePath $ImageFile

# Add new MSI Win32 app.
#$InstallCommandLine = "msiexec.exe /i $($appFile) /qn"
#$UninstallCommandLine = "msiexec.exe /x {$($IntuneWinMetaData.ApplicationInfo.MsiInfo.MsiProductCode)} /qn"

# Add new EXE Win32 app.
$InstallCommandLine = "powershell.exe -executionpolicy bypass -windowstyle hidden .\wingetSysCmd.ps1 install --exact --silent --id $appWinGetID --log $env:TEMP\Install-$appWinGetID.txt --accept-package-agreements --accept-source-agreements"
$UninstallCommandLine = "powershell.exe -executionpolicy bypass -windowstyle hidden $Env:PROGRAMDATA\WinGetSys\wingetSysCmd.ps1 uninstall --exact --silent --id $appWinGetID --log C:\Windows\Temp\Uninstall-$appWinGetID.txt"
Add-IntuneWin32App -FilePath $IntuneWinFile.Path -DisplayName $DisplayName -Description $appDescription -Publisher $appPublisher -AppVersion $appVersion -Developer $appDeveloper -InformationURL $appInfoURL -PrivacyURL $appPrivacyURL -Owner $appOwner -CompanyPortalFeaturedApp $appFeatured -Notes $appNotes -InstallExperience user -RestartBehavior suppress -DetectionRule $DetectionRule -RequirementRule $RequirementRule -InstallCommandLine $InstallCommandLine -UninstallCommandLine $UninstallCommandLine -Icon $appIcon -Verbose

# Create an available assignment for all users
$AppID = (Get-IntuneWin32App -DisplayName $DisplayName).ID
Add-IntuneWin32AppAssignmentAllUsers -ID $AppID -Intent "available" -Verbose

# Create a required assignment for all devices - useful for REQUIRED applications, such as the Automate agent.
#Add-IntuneWin32AppAssignmentAllDevices -TenantName $TenantName -DisplayName $DisplayName -Intent "required" -Verbose

# Create a required assignment for a specific group
#Add-IntuneWin32AppAssignmentGroup -TenantName $TenantName -DisplayName $DisplayName -GroupID "Group" -Intent "required" -Verbose