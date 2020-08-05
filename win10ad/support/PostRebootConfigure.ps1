param([string]$domain="opsaaddemo.local",[string]$repo="",[string]$Folder="C:\OpsgilityTraining")

Begin {
    Function Expand-Files {
        [cmdletbinding()]
        Param (
            [parameter(ValueFromPipeline=$true)]
            [Object[]]$Files,
            [string]$Destination
        )
    
        foreach ($file in $files)
        {
            $fileName = $file.FullName
            $fileBase = $file.BaseName
    
            write-output "Start unzip: $fileName to $Destination"
            
            $7zEXE = "$Folder\7z\7za.exe"
    
            cmd /c "$7zEXE x -y -o$Destination\$fileBase $fileName" | Add-Content $cmdLogPath
            
            write-output "Finish unzip: $fileName to $Destination"
        }
    }
}

Process {
# Download post-migration conteent files
Write-Output "Download with Bits"
$sourceFolder = "$repo/support"
$downloads = @(
    "$sourceFolder/StudentFiles.zip"
)
$destinationFiles = @(
    "$Folder\StudentFiles.zip"
)

Import-Module BitsTransfer
0..($downloads.Length-1) | %{
    Write-Host "Download $($downloads[$_]) to $($destinationFiles[$_])..."
    Start-BitsTransfer -Source $downloads[$_] -Destination $destinationFiles[$_]
}

# extract content
$FileItems = $destinationFiles | Get-Item
$FileItems | Extract-Files -Destination $Folder

&"$Folder\StudentFiles\DomainUpdate.ps1" -SharePath "$Folder\StudentFiles\LabFiles"


}
