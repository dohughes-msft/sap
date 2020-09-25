<#
.SYNOPSIS
    Display a list of VMs and their tags
.EXAMPLE
    PS C:\> show_vms_and_tags.ps1
.INPUTS
    -allSubs                : false if only the current subscription/context should be examined (default)
                              true if all available subscriptions in the current tenant should be examined
    -export <filename.csv>  : export to CSV instead of screen output
.OUTPUTS
    Display a list of VMs, tag keys and tag values
.NOTES
    None.
#>

param (
    [switch]$allSubs=$false,
    [string]$export
)

$report = @()

function getVMs {
    $vms = Get-AzVM
    foreach ($vm in $vms) {
        $keys = $vm.Tags.Keys
        foreach ($key in $keys) {
            $row = [PSCustomObject]@{"VM Name"=$vm.Name;"Tag key"=$key;"Tag value"=$vm.Tags.$key}
            $script:report += $row
        }
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
