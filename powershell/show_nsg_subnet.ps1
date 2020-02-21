# This PowerShell script will print a list of VNETs, subnets, and their associated NSGs.
# The current subscription context will be used unless parameter -allSubs is given in which case all accessible subscriptions will be examined.

param ([switch]$allSubs)

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        Get-AzVirtualNetwork | Select-Object @{n='VNETName';e={$_.Name}} -ExpandProperty Subnets | Select-Object VNETName, @{n='SubnetName';e={$_.Name}}, @{n='NSG';e={
            if ($_.NetworkSecurityGroup ) { $_.NetworkSecurityGroup } 
            else { [pscustomobject] @{ Id='' } } 
            } } | Select-Object VNETName, SubnetName -ExpandProperty NSG | Select-Object @{n='Subscription';e={$sub.Name}}, VNETName, SubnetName, @{n='NSG';e={$_.Id -replace '.*/'}} -Unique
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
}
else {
    $sub = (Get-AzContext).Subscription
    Get-AzVirtualNetwork | Select-Object @{n='VNETName';e={$_.Name}} -ExpandProperty Subnets | Select-Object VNETName, @{n='SubnetName';e={$_.Name}}, @{n='NSG';e={
        if ($_.NetworkSecurityGroup ) { $_.NetworkSecurityGroup } 
        else { [pscustomobject] @{ Id='' } } 
        } } | Select-Object VNETName, SubnetName -ExpandProperty NSG | Select-Object @{n='Subscription';e={$sub.Name}}, VNETName, SubnetName, @{n='NSG';e={$_.Id -replace '.*/'}} -Unique
}