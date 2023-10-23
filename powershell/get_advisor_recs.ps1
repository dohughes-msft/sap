# Docs at https://learn.microsoft.com/en-us/rest/api/advisor/recommendations/list?tabs=HTTP
# Get-AzAdvisorRecommendation

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

$restUri = "https://management.azure.com/subscriptions/$subId/providers/Microsoft.Advisor/recommendations?api-version=2023-01-01"

$response = Invoke-RestMethod -Uri $restUri -Method Get -Headers $authHeader

#foreach($line in $response.value.properties) {
#   Write-Output $line.category
#}

$response.value.properties | Where-Object {$_.category -eq 'Security'} | Format-Table -AutoSize
