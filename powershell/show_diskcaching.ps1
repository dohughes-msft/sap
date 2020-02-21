# This PowerShell script will print a list of VMs, disks, and their caching settings.
# The current subscription context will be used unless parameter -allSubs is given in which case all accessible subscriptions will be examined.

param ([switch]$allSubs)

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        Get-AzVM | Select-Object @{n='VMName';e={$_.Name}} -ExpandProperty StorageProfile | Select-Object VMName -ExpandProperty DataDisks | Select-Object @{n='Subscription';e={$sub.Name}}, VMName, @{n='DiskName';e={$_.Name}}, Caching, WriteAcceleratorEnabled | Format-Table
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
}
else {
    $sub = (Get-AzContext).Subscription
    Get-AzVM | Select-Object @{n='VMName';e={$_.Name}} -ExpandProperty StorageProfile | Select-Object VMName -ExpandProperty DataDisks | Select-Object @{n='Subscription';e={$sub.Name}}, VMName, @{n='DiskName';e={$_.Name}}, Caching, WriteAcceleratorEnabled | Format-Table
}