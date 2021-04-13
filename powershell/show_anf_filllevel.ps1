<#
.SYNOPSIS
    Display a list of Azure NetApp Files volumes and their current filling level
.EXAMPLE
    PS C:\> show_anf_filllevel.ps1
.INPUTS
    Specify the resource groups to examine in the variable $resourceGroups below
.OUTPUTS
    Display a list of account/pool/volume and current filling level
.NOTES
    This script requires the Az module Az.NetAppFiles. You can install it with:
    Install-Module -Name Az.NetAppFiles
#>

$resourceGroups = @("hanascaleout-rg1","hanascaleout-rg1b","anf-rg1")

$endTime = Get-Date
$startTime = $endTime.AddMinutes(-5)
$WarningPreference = "SilentlyContinue"
[System.Collections.ArrayList]$resultTable = @()

foreach($resourceGroup in $resourceGroups) {
    $netAppAccounts = Get-AzNetAppFilesAccount -ResourceGroupName $resourceGroup
    foreach($netAppAccount in $netAppAccounts) {
        $netAppPools = Get-AzNetAppFilesPool -AccountObject $netAppAccount
        foreach($netAppPool in $netAppPools) {
            $netAppVolumes = Get-AzNetAppFilesVolume -PoolObject $netAppPool
            foreach($netAppVolume in $netAppVolumes) {
                $fillLevel = (Get-AzMetric -ResourceId $netAppVolume.id -MetricName VolumeConsumedSizePercentage -TimeGrain 00:05:00 -StartTime $startTime -EndTime $endTime).Data.Average
                $resultRow = [PSCustomObject]@{"Account/Pool/Volume"=$netAppVolume.Name;"Fill %"=[math]::Round($fillLevel,2)}
                $resultTable.Add($resultRow) | Out-Null
            }
        }
    }
}

$resultTable
