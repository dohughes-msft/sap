<#
.SYNOPSIS
    Display a list of availability sets and their associated proximity placement groups
.EXAMPLE
    PS C:\> show_ppg_avset.ps1
.INPUTS
    -allSubs : false if only the current subscription/context should be examined (default)
               true if all available subscriptions in the current tenant should be examined
.OUTPUTS
    Display a list of AvSets and their PPGs
.NOTES
    None
#>

param (
    [switch]$allSubs
)

function getAvSets {
    $script:result += Get-AzAvailabilitySet `
        | Select-Object `
            Name, `
            @{n='PPG';e={
                if ( $_.ProximityPlacementGroup ) { $_.ProximityPlacementGroup } 
                else { [pscustomobject] @{ Id='' }}
            }} `
        | Select-Object `
            @{n='Subscription';e={$sub.Name}}, `
            @{n='AvSet name';e={$_.Name}}, `
            @{n='PPG name';e={$_.PPG.Id -replace '.*/'}}
}

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        getAvSets
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
}
else {
    $sub = (Get-AzContext).Subscription
    getAvSets
}

$result | Format-Table -AutoSize