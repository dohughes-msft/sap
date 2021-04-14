<#
.SYNOPSIS
    Display a list of Azure NetApp Files volumes and their current filling level
.EXAMPLE
    PS C:\> show_anf_filllevel.ps1
.INPUTS
    You can either let the script find ANF-related resource groups automatically via Azure Resource Graph, or specify them manually in variable $resourceGroups below.
.OUTPUTS
    Display a list of account/pool/volume and current filling level
.NOTES
    This script requires the Az module Az.ResourceGraph. You can install it with:
    Install-Module -Name Az.ResourceGraph
#>

$netAppVolumes = Search-AzGraph -Query "Resources | where type == 'microsoft.netapp/netappaccounts/capacitypools/volumes' | project name, id | order by name"

$endTime = Get-Date
$startTime = $endTime.AddMinutes(-5)
$WarningPreference = "SilentlyContinue"
[System.Collections.ArrayList]$resultTable = @()

foreach($netAppVolume in $netAppVolumes) {
    $fillLevel = (Get-AzMetric -ResourceId $netAppVolume.id -MetricName VolumeConsumedSizePercentage -TimeGrain 00:05:00 -StartTime $startTime -EndTime $endTime).Data.Average
    $resultRow = [PSCustomObject]@{"Account/Pool/Volume"=$netAppVolume.name;"Fill %"=[math]::Round($fillLevel,2)}
    $resultTable.Add($resultRow) | Out-Null
}

$resultTable
