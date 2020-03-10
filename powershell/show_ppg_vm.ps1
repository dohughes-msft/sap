<#
.SYNOPSIS
    Display a list of VMs and their associated proximity placement groups
.EXAMPLE
    PS C:\> show_ppg_vm.ps1
.INPUTS
    -allSubs : false if only the current subscription/context should be examined (default)
               true if all available subscriptions in the current tenant should be examined
.OUTPUTS
    Display a list of VMs and their PPGs
.NOTES
    None
#>

param (
    [switch]$allSubs
)

function getVMs {
    $script:result += Get-AzVM `
        | Select-Object `
            Name, `
            @{n='PPG';e={
                if ( $_.ProximityPlacementGroup ) { $_.ProximityPlacementGroup } 
                else { [pscustomobject] @{ Id='' }}
            }} `
        | Select-Object `
            @{n='Subscription';e={$sub.Name}}, `
            @{n='VM name';e={$_.Name}}, `
            @{n='PPG name';e={$_.PPG.Id -replace '.*/'}} -Unique
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

Write-Output `n"The above output includes VMs whose PPG is inherited from an availability set."`n