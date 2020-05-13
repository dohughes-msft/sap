<#
.SYNOPSIS
    Display a list of VMs
.EXAMPLE
    PS C:\> show_vms.ps1
.INPUTS
    -allSubs                : false if only the current subscription/context should be examined (default)
                              true if all available subscriptions in the current tenant should be examined
    -days                   : the number of days (from today) to go back and retrieve CPU usage info for
    -export <filename.csv>  : export to CSV instead of screen output
.OUTPUTS
    Display a list of subscriptions, VMs, VM sizes, running states
.NOTES
    None.
#>

param (
    [switch]$allSubs=$false,
    [int]$days=30,
    [string]$export
)

$endDate = Get-Date
$startDate = $endDate.AddDays(-$days)
$timeSpan = New-TimeSpan -Days 1
$WarningPreference = "SilentlyContinue"
$report = @()

<# function getVMs {
    $script:result += Get-AzVM -Status `
        | Select-Object `
            @{n='Subscription';e={$sub.Name}},
            ResourceGroupName,
            Location,
            Name,
            @{n='Size';e={$_.HardwareProfile.VmSize}},
            PowerState
} #>

function getVMs {
    $vms = Get-AzVM -Status
    foreach($vm in $vms) {
        $maxCPU = ((Get-AzMetric -ResourceId $vm.Id -AggregationType Maximum -MetricName "Percentage CPU" -StartTime $startDate -EndTime $endDate -TimeGrain $timeSpan -DetailedOutput).Data.Maximum | Measure-Object -Maximum).Maximum
        $avgCPU = ((Get-AzMetric -ResourceId $vm.Id -AggregationType Average -MetricName "Percentage CPU" -StartTime $startDate -EndTime $endDate -TimeGrain $timeSpan -DetailedOutput).Data.Average | Measure-Object -Average).Average
        $row = [PSCustomObject]@{"Subscription"=$sub.Name;"Resource group"=$vm.ResourceGroupName;"Location"=$vm.Location;"VM name"=$vm.Name;"Size"=$vm.HardwareProfile.VmSize;"Power state"=$vm.PowerState;"Maximum CPU"=[math]::Round($maxCPU,2);"Average CPU"=[math]::Round($avgCPU,2)}
        $script:report += $row
    }
}

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        getVMs
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
}
else {
    $sub = (Get-AzContext).Subscription
    getVMs
}

if ($PSBoundParameters.ContainsKey('export')) {
    $report | Export-Csv -Path .\$export
} else {
    $report | Format-Table -AutoSize
}
