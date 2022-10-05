<#
.SYNOPSIS
    Display a list of Azure NetApp Files volumes and their current filling level
.EXAMPLE
    PS C:\> show_anf_filllevel.ps1 [-export output.csv]
.INPUTS
    Parameter -export can be used to write the output to a CSV file instead of on-screen.
.OUTPUTS
    Display a list of account/pool/volume, volume size and current filling level
.NOTES
    This script requires the Az module Az.ResourceGraph. You can install it with:
    Install-Module -Name Az.ResourceGraph
#>

param (
    [string]$export
)

$netAppVolumes = Search-AzGraph -First 200 -Query "Resources | where type == 'microsoft.netapp/netappaccounts/capacitypools/volumes' | project name, id, size=properties.usageThreshold, tier=properties.serviceLevel | order by name"

$endTime = Get-Date
$startTime = $endTime.AddMinutes(-5)
$WarningPreference = "SilentlyContinue"
[System.Collections.ArrayList]$resultTable = @()

foreach($netAppVolume in $netAppVolumes) {
    $fillLevel = (Get-AzMetric -ResourceId $netAppVolume.id -MetricName VolumeConsumedSizePercentage -TimeGrain 00:05:00 -StartTime $startTime -EndTime $endTime).Data.Average
    $resultRow = [PSCustomObject]@{"Account/Pool/Volume"=$netAppVolume.name;"Tier"=$netAppVolume.tier;"Fill %"=[math]::Round($fillLevel,2);"Size"=$netAppVolume.size}
    $resultTable.Add($resultRow) | Out-Null
}

if ($PSBoundParameters.ContainsKey('export')) {
    $resultTable | Export-Csv -Path .\$export
} else {
    $resultTable | Format-Table -AutoSize
}
