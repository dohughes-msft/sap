<#
.SYNOPSIS
    Display a list of VMs, NICs and their associated Network Security Group(s)
.EXAMPLE
    PS C:\> show_nsg_nic.ps1
.INPUTS
    -allSubs : false if only the current subscription/context should be examined (default)
               true if all available subscriptions in the current tenant should be examined
.OUTPUTS
    Display a list of VMs, NICs and their NSGs
.NOTES
    Only NICs that are assigned to a VM are shown.
#>

# This PowerShell script will print a list of VMs, NICs, and their associated NSGs.
# The current subscription context will be used unless parameter -allSubs is given in which case all accessible subscriptions will be examined.

param (
    [switch]$allSubs
)

function getVMs {
    $script:result += Get-AzNetworkInterface `
        | Where-Object {$_.VirtualMachine.Id -ne $null} `
        | Select-Object `
            @{n='VMName';e={$_.VirtualMachine.Id -replace '.*/'}}, `
            @{n='NICName';e={$_.Name}}, `
            @{n='NSG';e={
                if ($_.NetworkSecurityGroup ) { $_.NetworkSecurityGroup } 
                else { [pscustomobject] @{ Id='' } }
            }} `
        | Select-Object `
            VMName, `
            NICName `
            -ExpandProperty NSG `
        | Select-Object `
            @{n='Subscription';e={$sub.Name}}, `
            VMName, `
            NICname, `
            @{n='NSG';e={$_.Id -replace '.*/'}} -Unique
}

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        getVMs
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
}
else {
    $sub = (Get-AzContext).Subscription
    getVMs
}

$result | Format-Table -AutoSize