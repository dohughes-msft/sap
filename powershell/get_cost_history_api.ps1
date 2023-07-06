$subscriptionId = "your-subscription-id"
$resourceId = "/subscriptions/$subscriptionId/resourceGroups/your-resource-group/providers/Microsoft.Compute/virtualMachines/your-vm-name"
$startDate = "2023-01-01"
$endDate = "2023-06-30"
$granularity = "Daily"

$uri = "https://management.azure.com$resourceGroupId/providers/Microsoft.CostManagement/query?api-version=2023-03-01"
$body = @{
    type = "Usage"
    timeframe = "Custom"
    timePeriod = @{
        from = $startDate
        to = $endDate
    }
    dataset = @{
        granularity = $granularity
#        aggregation = @(
#            @{
#                type = "Sum"
#                name = "PreTaxCost"
#            }
#        )
        configuration = @{
            columns = @(
                @{
                    name = "ResourceId"
                    type = "Dimension"
                }
                @{
                    name = "PreTaxCost"
                    type = "Metric"
                }
            )
        }
        filter = @{
            dimensions = @{
                    name = "ResourceId"
                    operator = "In"
                    values = @($resourceId)
                }
        }
    }
} | ConvertTo-Json -Depth 10

$body


$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
   'Content-Type'='application/json'
   'Authorization'='Bearer ' + $token.AccessToken
}

#$token = [Microsoft.Azure.Commands.Common.Authentication.AzureSession]::Instance.AuthenticationFactory.Authenticate($null, $null, $subscriptionId).AccessToken
$response = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $body

#$response.properties.rows | Select-Object -Property UsageDate, PreTaxCost
$response.properties.rows