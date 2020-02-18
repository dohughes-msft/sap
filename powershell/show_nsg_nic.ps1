# This PowerShell script will print a list of subscriptions, VMs, NICs, and their associated NSGs

$context = Get-AzContext
$tenantId = $context.Tenant
$subs = Get-AzSubscription -TenantId $tenantId

foreach($sub in $subs) {
    $sub | Select-AzSubscription | Out-Null
    Get-AzNetworkInterface | Select-Object @{n='VMName';e={$_.VirtualMachine.Id -replace '.*/'}}, @{n='NICName';e={$_.Name}}, @{n='NSG';e={
        if ($_.NetworkSecurityGroup ) { $_.NetworkSecurityGroup } 
    else { [pscustomobject] @{ Id='' } } 
        } } | Select-Object VMName, NICName -ExpandProperty NSG | Select-Object @{n='SubName';e={$sub.Name}}, VMName, NICname, @{n='NSG';e={$_.Id -replace '.*/'}} -Unique
    }