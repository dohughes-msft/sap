<#
.SYNOPSIS
    Display a list of VMs, disks and their caching settings
.EXAMPLE
    PS C:\> show_diskcaching.ps1
.INPUTS
    -allSubs : false if only the current subscription/context should be examined (default)
               true if all available subscriptions in the current tenant should be examined
.OUTPUTS
    Display a list of VMs, disks, and caching settings
.NOTES
    None.
#>

param (
    [switch]$allSubs
)

function getVMs {
    $script:result += Get-AzVM `
        | Select-Object `
            @{n='VMName';e={$_.Name}} `
            -ExpandProperty StorageProfile `
        | Select-Object `
            VMName `
            -ExpandProperty DataDisks `
        | Select-Object `
            @{n='Subscription';e={$sub.Name}}, `
            VMName, `
            @{n='DiskName';e={$_.Name}}, `
            Caching, `
            WriteAcceleratorEnabled
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

$result | Format-Table -AutoSize