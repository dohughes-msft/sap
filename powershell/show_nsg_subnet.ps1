# This PowerShell script will print a list of subscriptions, VNETs, subnets, and their associated NSGs

$context = Get-AzContext
$tenantId = $context.Tenant
$subs = Get-AzSubscription -TenantId $tenantId

foreach($sub in $subs) {
    $sub | Select-AzSubscription | Out-Null
    Get-AzVirtualNetwork | Select-Object @{n='VNETName';e={$_.Name}} -ExpandProperty Subnets | Select-Object VNETName, @{n='SubnetName';e={$_.Name}}, @{n='NSG';e={
        if ($_.NetworkSecurityGroup ) { $_.NetworkSecurityGroup } 
         else { [pscustomobject] @{ Id='' } } 
         } } | Select-Object VNETName, SubnetName -ExpandProperty NSG | Select-Object @{n='SubName';e={$sub.Name}}, VNETName, SubnetName, @{n='NSG';e={$_.Id -replace '.*/'}} -Unique
}