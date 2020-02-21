# This PowerShell script will print a list of VMs, NICs, and their associated ASGs.
# The current subscription context will be used unless parameter -allSubs is given in which case all accessible subscriptions will be examined.

param ([switch]$allSubs)

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        Get-AzNetworkInterface | Select-Object @{n='VMName';e={$_.VirtualMachine.Id -replace '.*/'}}, @{n='NICName';e={$_.Name}} -ExpandProperty IpConfigurations | Select-Object VMName, NICName, @{n='ASG';e={
            if ( $_.ApplicationSecurityGroups ) { $_.ApplicationSecurityGroups } 
            else { [pscustomobject] @{ Id='' } } 
            } } | Select-Object VMName, NICName -ExpandProperty ASG | Select-Object @{n='Subscription';e={$sub.Name}}, VMName, NICName, @{n='ASGName';e={$_.Id -replace '.*/'}} -Unique
        Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
    }
}
else {
    $sub = (Get-AzContext).Subscription
    Get-AzNetworkInterface | Select-Object @{n='VMName';e={$_.VirtualMachine.Id -replace '.*/'}}, @{n='NICName';e={$_.Name}} -ExpandProperty IpConfigurations | Select-Object VMName, NICName, @{n='ASG';e={
        if ( $_.ApplicationSecurityGroups ) { $_.ApplicationSecurityGroups } 
        else { [pscustomobject] @{ Id='' } } 
        } } | Select-Object VMName, NICName -ExpandProperty ASG | Select-Object @{n='Subscription';e={$sub.Name}}, VMName, NICName, @{n='ASGName';e={$_.Id -replace '.*/'}} -Unique
}