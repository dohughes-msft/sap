<#
.SYNOPSIS
    Display a list of VNETs, subnets and their associated Network Security Group(s)
.EXAMPLE
    PS C:\> show_nsg_subnet.ps1
.INPUTS
    -allSubs : false if only the current subscription/context should be examined (default)
               true if all available subscriptions in the current tenant should be examined
.OUTPUTS
    Display a list of VNETs, subnets and their NSGs
.NOTES
    None
#>

param (
    [switch]$allSubs
)
function getVNETs {
    $script:result += Get-AzVirtualNetwork `
        | Select-Object `
            @{n='VNETName';e={$_.Name}} `
            -ExpandProperty Subnets `
        | Select-Object `
            VNETName, `
            @{n='SubnetName';e={$_.Name}}, `
            @{n='NSG';e={
                if ($_.NetworkSecurityGroup ) { $_.NetworkSecurityGroup } 
                else { [pscustomobject] @{ Id='' } }
            }} `
        | Select-Object `
            VNETName, `
            SubnetName `
            -ExpandProperty NSG `
        | Select-Object `
            @{n='Subscription';e={$sub.Name}}, `
            VNETName, `
            SubnetName, `
            @{n='NSG';e={$_.Id -replace '.*/'}} -Unique
}

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        getVNETs
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
}
else {
    $sub = (Get-AzContext).Subscription
    getVNETs
}

$result | Format-Table -AutoSize