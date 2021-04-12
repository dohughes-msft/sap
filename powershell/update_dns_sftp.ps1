
param (
    [string]$resourceGroup="sftp-rg2"
)

$containerGroups = Get-AzContainerGroup -ResourceGroupName $resourceGroup
foreach ($group in $containerGroups) {
    if ($group.Tags.role -eq "primary") {
        Write-Output "$($group.Name) is the primary"
    }
}
