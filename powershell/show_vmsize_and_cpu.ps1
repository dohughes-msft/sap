# This PowerShell script will print a list of subscriptions, VMs, VM sizes, and average and maximum CPU over a specified period.
# The current subscription context will be used unless parameter -allSubs is given in which case all accessible subscriptions will be examined.
# Define the number of days to collect CPU data using parameter -days. E.g. -days 7 will collect data from the last 7 days. Default 30 days.
# This script may take a long time since retrieving metrics for each VM is time-consuming.

param (
    [switch]$allSubs=$false,
    [int]$days=30
)

$endDate = Get-Date
$startDate = $endDate.AddDays(-$days)
$timeSpan = New-TimeSpan -Days 1
$WarningPreference = "SilentlyContinue"

Write-Output `n"Displaying VM CPU metrics over the past $days days"

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        $vms = Get-AzVM
        foreach($vm in $vms) {
            $size = $vm.HardwareProfile.VmSize
            $maxCPU = ((Get-AzMetric -ResourceId $vm.Id -AggregationType Maximum -MetricName "Percentage CPU" -StartTime $startDate -EndTime $endDate -TimeGrain $timeSpan -DetailedOutput).Data.Maximum | Measure-Object -Maximum).Maximum
            $avgCPU = ((Get-AzMetric -ResourceId $vm.Id -AggregationType Average -MetricName "Percentage CPU" -StartTime $startDate -EndTime $endDate -TimeGrain $timeSpan -DetailedOutput).Data.Average | Measure-Object -Average).Average
            $output = [PSCustomObject]@{"Subscription"=$sub.Name;"Virtual Machine"=$vm.Name;"Size"=$size;"Maximum CPU"=$maxCPU;"Average CPU"=[math]::Round($avgCPU,2)}
            $output
        }
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
}
else {
    $sub = (Get-AzContext).Subscription
    Write-Output "Subscription: $($sub.Name)"
    $vms = Get-AzVM
    foreach($vm in $vms) {
        $size = $vm.HardwareProfile.VmSize
        $maxCPU = ((Get-AzMetric -ResourceId $vm.Id -AggregationType Maximum -MetricName "Percentage CPU" -StartTime $startDate -EndTime $endDate -TimeGrain $timeSpan -DetailedOutput).Data.Maximum | Measure-Object -Maximum).Maximum
        $avgCPU = ((Get-AzMetric -ResourceId $vm.Id -AggregationType Average -MetricName "Percentage CPU" -StartTime $startDate -EndTime $endDate -TimeGrain $timeSpan -DetailedOutput).Data.Average | Measure-Object -Average).Average
        $output = [PSCustomObject]@{"Virtual Machine"=$vm.Name;"Size"=$size;"Maximum CPU"=$maxCPU;"Average CPU"=[math]::Round($avgCPU,2)}
        $output
    }
}