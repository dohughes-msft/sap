# This PowerShell script will print a list of availability sets and their associated proximity placement groups.
# The current subscription context will be used unless parameter -allSubs is given in which case all accessible subscriptions will be examined.

param ([switch]$allSubs)

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        Get-AzVM | Select-Object Name, @{n='PPG';e={
            if ( $_.ProximityPlacementGroup ) { $_.ProximityPlacementGroup } 
            else { [pscustomobject] @{ Id='' } } 
            } } | Select-Object Name -ExpandProperty PPG | Select-Object @{n='Subscription';e={$sub.Name}}, @{n='VM name';e={$_.Name}}, @{n='PPG name';e={$_.Id -replace '.*/'}} -Unique
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
}
else {
    $sub = (Get-AzContext).Subscription
    Get-AzVM | Select-Object Name, @{n='PPG';e={
        if ( $_.ProximityPlacementGroup ) { $_.ProximityPlacementGroup } 
        else { [pscustomobject] @{ Id='' } } 
        } } | Select-Object Name -ExpandProperty PPG | Select-Object @{n='Subscription';e={$sub.Name}}, @{n='VM name';e={$_.Name}}, @{n='PPG name';e={$_.Id -replace '.*/'}} -Unique
}

Write-Output `n"The above output includes VMs whose PPG is inherited from an availability set."