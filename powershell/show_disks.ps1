<#
.SYNOPSIS
    Display a list of disks
.EXAMPLE
    PS C:\> show_disks.ps1
.INPUTS
    -allSubs                : false if only the current subscription/context should be examined (default)
                              true if all available subscriptions in the current tenant should be examined
    -export <filename.csv>  : Export to CSV instead of screen output
.OUTPUTS
    Display a list of subscriptions, disks, disk sizes, disk states
.NOTES
    None.
#>

param (
    [switch]$allSubs=$false,
    [string]$export
)

function getDisks {
    $script:result += Get-AzDisk `
        | Select-Object `
            @{n='Subscription';e={$sub.Name}},
            ResourceGroupName,
            Location,
            @{n='DiskName';e={$_.Name}},
            @{n='SKU';e={$_.Sku.Name}},
            DiskSizeGB,
            DiskState,
            @{n='ManagedBy';e={$_.ManagedBy -replace '.*/'}}
}

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        getDisks
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
}
else {
    $sub = (Get-AzContext).Subscription
    getDisks
}

if ($PSBoundParameters.ContainsKey('export')) {
    $result | Export-Csv -Path .\$export
} else {
    $result | Format-Table -AutoSize
}
