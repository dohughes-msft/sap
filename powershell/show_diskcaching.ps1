# This PowerShell script will print a list of subscriptions, VMs, disks, and their caching settings

$context = Get-AzContext
$tenantId = $context.Tenant
$subs = Get-AzSubscription -TenantId $tenantId

foreach($sub in $subs) {
    $sub | Select-AzSubscription | Out-Null
    Get-AzVM | Select-Object @{n='VMName';e={$_.Name}} -ExpandProperty StorageProfile | Select-Object VMName -ExpandProperty DataDisks | Select-Object @{n='SubName';e={$sub.Name}}, VMName, @{n='DiskName';e={$_.Name}}, Caching, WriteAcceleratorEnabled | Format-Table
}