#$subscriptionId = "your-subscription-id"
#$resourceId = "/subscriptions/$subscriptionId/resourceGroups/your-resource-group/providers/Microsoft.Compute/virtualMachines/your-vm-name"
$startDate = "2023-01-01"
$endDate = "2023-06-30"
$granularity = "Daily"

#$resourceId = "/subscriptions/f3bd1cf9-6b3f-4fda-b3f9-83e9467674cf/resourcegroups/identity-northeurope-rg1/providers/microsoft.compute/disks/advm2_osdisk_1_c91c98fa47654f15a1c902db763ea453"
#$resourceGroupId = "/subscriptions/f3bd1cf9-6b3f-4fda-b3f9-83e9467674cf/resourcegroups/identity-northeurope-rg1"
$resourceId = "/subscriptions/3d426a17-f592-4e2c-b0ad-3742486b4c73/resourceGroups/anghasten-storage/providers/Microsoft.Storage/storageAccounts/brfang"
$resourceGroupId = "/subscriptions/3d426a17-f592-4e2c-b0ad-3742486b4c73/resourceGroups/anghasten-storage"
#$resourceGroupId = $resourceId.Split("/")[1,2];
#$resourceGroupId = $resourceId.Substring(0,$string.IndexOf(","))
#$resourceGroupId = $resourceId.Substring(0,4)

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