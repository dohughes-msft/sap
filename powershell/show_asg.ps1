<#
.SYNOPSIS
    Display a list of VMs, NICs and their associated Application Security Group(s)
.EXAMPLE
    PS C:\> show_asg.ps1
.INPUTS
    -allSubs : false if only the current subscription/context should be examined (default)
               true if all available subscriptions in the current tenant should be examined
.OUTPUTS
    Display a list of VMs, NICs and their ASGs
.NOTES
    Only NICs that are assigned to a VM are shown.
#>

param (
    [switch]$allSubs
)

function getVMs {
    $script:result += Get-AzNetworkInterface `
        | Where-Object {$_.VirtualMachine.Id -ne $null} `
        | Select-Object `
            @{n='VMName';e={$_.VirtualMachine.Id -replace '.*/'}}, `
            @{n='NICName';e={$_.Name}} `
            -ExpandProperty IpConfigurations `
        | Select-Object `
            VMName, `
            NICName, `
            @{n='ASG';e={
                if ( $_.ApplicationSecurityGroups ) { $_.ApplicationSecurityGroups } 
                else { [pscustomobject] @{ Id='' } } 
            }} `
        | Select-Object `
            VMName, `
            NICName `
            -ExpandProperty ASG `
        | Select-Object `
            @{n='Subscription';e={$sub.Name}}, `
            VMName, `
            NICName, `
            @{n='ASGName';e={$_.Id -replace '.*/'}} `
            -Unique
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
} else {
    $sub = (Get-AzContext).Subscription
    getVMs
}

$result | Format-Table -AutoSize