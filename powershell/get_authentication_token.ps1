#Connect-AzAccount

$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
   'Content-Type'='application/json'
   'Authorization'='Bearer ' + $token.AccessToken
}
$subId = $azContext.Subscription.Id

#$restUri = "https://management.azure.com/subscriptions/$subId/providers/Microsoft.Compute/virtualMachines?api-version=2021-03-01"
#$restUri = "https://management.azure.com/subscriptions/$subId/providers/Microsoft.Consumption/usageDetails?api-version=2021-10-01&$filter=properties/usageEnd+ge+'2023-02-01'+AND+properties/usageEnd+le+'2023-02-28'"
# the above does not work on MOSP
$restUri = "https://management.azure.com/subscriptions/$subId/providers/Microsoft.Consumption/usageDetails?api-version=2019-01-01&$filter=properties/usageEnd+ge+'2023-02-01'+AND+properties/usageEnd+le+'2023-02-28'"

$response = Invoke-RestMethod -Uri $restUri -Method Get -Headers $authHeader
