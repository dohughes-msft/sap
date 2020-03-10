# This PowerShell script will print a list of subscriptions, VMs, VM sizes, and average and maximum CPU over a specified period.
# The current subscription context will be used unless parameter -allSubs is given in which case all accessible subscriptions will be examined.
# Define the number of days to collect CPU data using parameter -days. E.g. -days 7 will collect data from the last 7 days. Default 30 days.
# This script may take a long time since retrieving metrics for each VM is time-consuming.

param (
    [switch]$allSubs=$false
)

if ($allSubs) {
    $tenantId = (Get-AzContext).Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        Get-AzVM | Select-Object @{n='Subscription';e={$sub.Name}}, ResourceGroupName, Name -ExpandProperty HardwareProfile
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
}
else {
    $sub = (Get-AzContext).Subscription
    Get-AzVM | Select-Object @{n='Subscription';e={$sub.Name}}, ResourceGroupName, Name -ExpandProperty HardwareProfile
}