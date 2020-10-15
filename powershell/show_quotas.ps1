<#
.SYNOPSIS
    Display current quota usages and limits for a given list of subscriptions.
.EXAMPLE
    PS C:\> show_quotas.ps1
.INPUTS
    -threshold <nn> : the limit in % above which a warning will be shown in the status column
    $inputs         : an inline variable in JSON format containing a list of subscriptions and locations that are in scope

    Example:
        $inputs = '[
            {
                "subscription": "5e3380ac-b138-468e-b4a7-aa9e24353999",
                "description": "Free text, this will show up in the output instead of the subscription ID",
                "locations": [
                    "westus2"
                ]
            },
            {
                "subscription": "9681cbdd-0eba-4428-a829-7a98fbd45d06",
                "description": "Free text, does not have to match the name in Azure",
                "locations": [
                    "westus2",
                    "eastus"
                ]
            }
        ]'

.OUTPUTS
    A table of subscriptions, locations and quotas. The final column will show a warning if that quota is over the threshold.
.NOTES
    Only quotas in use (>0) are shown.
#>

param(
    [int]$threshold=70
)

#Microsoft
$inputs = '{
    "subscription": "3e51b8f1-b856-4896-9a90-50ac02c27cf1",
    "description": "Dons Azure Playground",
    "locations": [
        "westus2",
        "westeurope",
        "northeurope"
    ]
}'

$inputsJson = $inputs | ConvertFrom-Json

# Save the current context as it will be lost when we cycle through the subscriptions
$context = Get-AzContext

foreach($sub in $inputsJson) {
    Set-AzContext -SubscriptionId $sub.subscription | Out-Null
    foreach($loc in $sub.locations) {
        $resultSet += Get-AzVMUsage -Location $loc | Where-Object CurrentValue -ne 0 | Select-Object CurrentValue, Limit -ExpandProperty Name | Select-Object @{n='Subscription';e={$sub.description}}, @{n='Location';e={$loc}}, @{n='Quota name';e={$_.LocalizedValue}}, CurrentValue, Limit, @{n='%used';e={[math]::Round(($_.CurrentValue/$_.Limit*100),2)}}, @{n='Status';e={
            if (($_.CurrentValue/$_.Limit*100) -gt $threshold) { "Warning" }
            else { "OK" }
        }}
    }
}

# Put back the original context
Set-AzContext -SubscriptionId $context.Subscription.Id | Out-Null

$resultSet | Format-Table