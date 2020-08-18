[cmdletbinding()]
param(
    [parameter(ValueFromPipeline=$true)]
    [string[]]$DomainUsers=@("Vera"),
    [string]$Domain="opsaaddemo.local",
    [string]$DefaultPass="demo@pass123",
    [string]$DefaultGroup="LabUsers",
    [string]$ShareName="LabFiles",
    [string]$SharePath="C:\StudentFiles\LabFiles",
    [switch]$NoAdmin)

Begin {
    Write-Host "Creating domain group..."
    $null=net group "$DefaultGroup" /domain /add
    If (-not $NoAdmin) { $null=net group "Domain Admins" "$DefaultGroup" /domain /add }
    Write-Host "Creating share for folder..."
    $null=net share "$ShareName"="$SharePath" /GRANT:Everyone,Full
    $null=icacls "$SharePath" /grant "$($DefaultGroup):M"
}

Process {
    ForEach ($User in $DomainUsers) {
        Write-Host "Creating user [$user]..."
        $null=net user $User $DefaultPass /domain /add
        $null=net group "$DefaultGroup" $User /domain /add
    }
}

End {

}