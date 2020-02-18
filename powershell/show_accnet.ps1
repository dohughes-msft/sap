# This PowerShell script will print a list of subscriptions, NICs, VMs, and their accelerated networking status

$context = Get-AzContext
$tenantId = $context.Tenant
$subs = Get-AzSubscription -TenantId $tenantId

foreach($sub in $subs) {
    $sub | Select-AzSubscription | Out-Null
    Get-AzNetworkInterface | Select-Object @{n='NICName';e={$_.Name}}, EnableAcceleratedNetworking -ExpandProperty VirtualMachine | Select-Object @{n='SubName';e={$sub.Name}}, NICName, @{n='VMName';e={$_.Id -replace '.*/'}}, EnableAcceleratedNetworking
}