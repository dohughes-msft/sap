<#
.SYNOPSIS
    Compile a list of all storage accounts and their used blob/file capacity
.EXAMPLE
    PS C:\> show_storage_usage.ps1
.INPUTS
    -allSubs               : false if only the current subscription/context should be examined (default)
                             true if all available subscriptions in the current tenant should be examined
    -export <filename.csv> : export to CSV instead of screen output
.OUTPUTS
    Display a list of subscriptions, storage accounts, tiers, SKUs and sizes
.NOTES
    
#>

param (
    [switch]$allSubs=$false,
    [string]$export
)

$WarningPreference = "SilentlyContinue"
function getStorageAccounts {
    $allStorageAccounts = Get-AzStorageAccount
    foreach ($storageAccount in $allStorageAccounts) {
        $blobServicesResourceId = "$($storageAccount.Id)/blobServices/default"
        $fileServicesResourceId = "$($storageAccount.Id)/fileServices/default"
        $endTime = (Get-Date).AddHours(-1)
        $startTime = $endTime.AddHours(-1)
        $blobSize = Get-AzMetric -ResourceId $blobServicesResourceId -MetricName "BlobCapacity" -StartTime $startTime -EndTime $endTime -TimeGrain 01:00:00
        $fileSize = Get-AzMetric -ResourceId $fileServicesResourceId -MetricName "FileCapacity" -StartTime $startTime -EndTime $endTime -TimeGrain 01:00:00
        $resultRow = [PSCustomObject]@{
            "Subscription"=$storageAccount.Id.Split("/")[2];
            "ResourceGroup"=$storageAccount.ResourceGroupName;
            "Name"=$storageAccount.StorageAccountName;
            "Location"=$storageAccount.Location;
            "Kind"=$storageAccount.Kind;
            "SKU"=$storageAccount.Sku.Name;
            "Tier"=$storageAccount.AccessTier;
            "BlobSize"=$blobSize.Data.Average;
            "FileSize"=$fileSize.Data.Average}
        $script:resultTable.Add($resultRow) | Out-Null
    }
}

[System.Collections.ArrayList]$resultTable = @()

if ($allSubs) {
    $context = Get-AzContext
    $tenantId = $context.Tenant
    $subs = Get-AzSubscription -TenantId $tenantId
    foreach($sub in $subs) {
        $sub | Select-AzSubscription | Out-Null
        getStorageAccounts
    }
    Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null
} else {
    $sub = (Get-AzContext).Subscription
    getStorageAccounts
}

if ($PSBoundParameters.ContainsKey('export')) {
    $resultTable | Export-Csv -Path .\$export
} else {
    $resultTable | Format-Table -AutoSize
}
