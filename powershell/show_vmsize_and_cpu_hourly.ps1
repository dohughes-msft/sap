
param (
    [int]$hours=24,
    [Parameter(Mandatory=$true)]$vmName
)

$endTime = Get-Date
$startTime = $endTime.AddHours(-$hours)
$timeSpan = New-TimeSpan -Hours 1
$WarningPreference = "SilentlyContinue"

Write-Output `n"Displaying VM CPU metrics over the past $hours hours for virtual machine $vmName"
$vm = Get-AzVM -Name $vmName
$size = $vm.HardwareProfile.VmSize
$avgCPU = Get-AzMetric -ResourceId $vm.Id -AggregationType Average -MetricName "Percentage CPU" -StartTime $startTime -TimeGrain $timeSpan
$maxCPU = Get-AzMetric -ResourceId $vm.Id -AggregationType Maximum -MetricName "Percentage CPU" -StartTime $startTime -TimeGrain $timeSpan

[System.Collections.ArrayList]$resultTable = @()

for ($counter=0; $counter -lt $hours; $counter++) {
    $resultRow = [PSCustomObject]@{"StartTime"=$avgCPU.Data[$counter].TimeStamp;"Maximum CPU"=$maxCPU.Data[$counter].Maximum;"Average CPU"=[math]::Round($avgCPU.Data[$counter].Average,2)}
    $resultTable.Add($resultRow) | Out-Null
}

$resultTable