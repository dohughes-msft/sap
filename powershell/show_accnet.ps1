# This PowerShell script will print a list of NICs, VMs, and their accelerated networking status.
# The current subscription context will be used unless parameter -allSubs is given in which case all accessible subscriptions will be examined.

param ([switch]$allSubs)

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        Get-AzNetworkInterface | Select-Object @{n='NICName';e={$_.Name}}, EnableAcceleratedNetworking -ExpandProperty VirtualMachine | Select-Object @{n='Subscription';e={$sub.Name}}, NICName, @{n='VMName';e={$_.Id -replace '.*/'}}, EnableAcceleratedNetworking
        
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
}
else {
    $sub = (Get-AzContext).Subscription
    Get-AzNetworkInterface | Select-Object @{n='NICName';e={$_.Name}}, EnableAcceleratedNetworking -ExpandProperty VirtualMachine | Select-Object @{n='Subscription';e={$sub.Name}}, NICName, @{n='VMName';e={$_.Id -replace '.*/'}}, EnableAcceleratedNetworking
}