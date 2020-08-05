param($domain, $password, $sourceRepo="https://github.com/opsgility/labs/raw/master/win10-domain-essentials/")

$smPassword = (ConvertTo-SecureString $password -AsPlainText -Force)

# Create folder for download and post run scripts
$opsDir = "C:\OpsgilityTraining"
New-Item -Path "$opsDir\7z" -ItemType Directory -Force

# Download post-migration script and 7z
Write-Output "Download with Bits"
$sourceFolder = "$sourceRepo/support"
$downloads = @(
    "$sourceFolder/PostRebootConfigure.ps1",
    "$sourceFolder/7z/7za.exe",
    "$sourceFolder/7z/7za.dll",
    "$sourceFolder/7z/7zxa.dll"
)
$destinationFiles = @(
    "$opsDir\PostRebootConfigure.ps1",
    "$opsDir\7z\7za.exe",
    "$opsDir\7z\7za.dll",
    "$opsDir\7z\7zxa.dll"
)

Import-Module BitsTransfer
Start-BitsTransfer -Source $downloads -Destination $destinationFiles

# Register task to run post-reboot script once host is rebooted after Hyper-V install
Write-Output "Register post-reboot script as scheduled task"
$action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\Powershell.exe" -Argument "-executionPolicy Unrestricted -File $opsDir\PostRebootConfigure.ps1 -Domain $domain -repo $sourceRepo"
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -TaskName "SetUpDC" -Action $action -Trigger $trigger -Principal $principal

# AD DS deployment
Install-WindowsFeature -Name "AD-Domain-Services" `
                       -IncludeManagementTools `
                       -IncludeAllSubFeature 

Install-ADDSForest -DomainName $domain `
                   -DomainMode Win2012 `
                   -ForestMode Win2012 `
                   -Force `
                   -SafeModeAdministratorPassword $smPassword 

