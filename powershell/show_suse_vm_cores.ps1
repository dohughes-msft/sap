<#
.SYNOPSIS
    Count cores for VMs using SUSE Linux PAYG and calculate the number of licenses needed
.EXAMPLE
    PS C:\> show_vm_size_os.ps1
.INPUTS
    -allSubs : false if only the current subscription/context should be examined (default)
               true if all available subscriptions in the current tenant should be examined
    -osOffer <offername> : name of the image to look for, default 'SLES-SAP'
.OUTPUTS
    A table of VMs, their core count and a summary of the number of licenses needed
.NOTES
    None
#>

param (
    [switch]$allSubs=$false,
    [string]$osOffer='SLES-SAP'
)

function getVMs {
    $script:result += Get-AzVM `
        | Where-Object {$_.StorageProfile.ImageReference.Offer -eq $osOffer} `
        | Select-Object `
            @{n='Subscription';e={$sub.Name}}, `
            ResourceGroupName, `
            Name, `
            @{n='Size';e={$_.HardwareProfile.VmSize}}, `
            @{n='Cores';e={$_.HardwareProfile.VmSize -replace '[a-zA-Z_]*([0-9]*).*','$1'}}, `
            @{n='License';e={
                if (($_.HardwareProfile.VmSize -replace '[a-zA-Z_]*([0-9]*).*','$1') -as [int] -le 2) {
                    "1-2 CPU"
                } elseif (($_.HardwareProfile.VmSize -replace '[a-zA-Z_]*([0-9]*).*','$1') -as [int] -le 4) {
                    "3-4 CPU"
                } else {
                    "5+  CPU"
                }
            }}
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

Write-Output "`nCounting VM cores for offer type: $osOffer"

$result | Format-Table -AutoSize
$numSmall = ($result | Where-Object "License" -eq '1-2 CPU').Count
$numMedium = ($result | Where-Object "License" -eq '3-4 CPU').Count
$numLarge = ($result | Where-Object "License" -eq '5+  CPU').Count
Write-Output "Number of 1-2 core licenses needed: $numSmall"
Write-Output "Number of 3-4 core licenses needed: $numMedium"
Write-Output "Number of 5+  core licenses needed: $numLarge"