<#
.SYNOPSIS
    Display a list of VMs, NICs and their accelerated networking status
.EXAMPLE
    PS C:\> show_accnet.ps1
.INPUTS
    -allSubs : false if only the current subscription/context should be examined (default)
               true if all available subscriptions in the current tenant should be examined
.OUTPUTS
    Display a list of VMs, NICs and their accelerated networking status
.NOTES
    None
#>

param (
    [switch]$allSubs
)

function getVMs {
    $script:result += Get-AzNetworkInterface `
        | Select-Object `
            @{n='Subscription';e={$sub.Name}}, `
            @{n='NICName';e={$_.Name}}, `
            @{n='VMName';e={$_.VirtualMachine.Id -replace '.*/'}}, `
            EnableAcceleratedNetworking
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
} else {
    $sub = (Get-AzContext).Subscription
    getVMs
}

$result | Format-Table -AutoSize