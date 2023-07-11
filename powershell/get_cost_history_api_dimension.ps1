<#
.SYNOPSIS
    Take a collection of given resource IDs and return the cost history for those resources. For this we use the Microsoft.CostManagement provider
    of the resource group containing the resource.
    This script uses direct API calls. For PowerShell consider using the Az.CostManagement module.

.PARAMETER ParameterName
    $resourceID[] (mandatory) : The resource IDs of the resources to be examined
    $startDate    (optional)  : The start date of the period to be examined (default is the first day of the month, 6 months ago)
    $endDate      (optional)  : The end date of the period to be examined (default is the last day of the previous month)

.INPUTS
    None

.OUTPUTS
    A table showing the cost history of the given resource(s) over the requested period

.EXAMPLE
    .\get_cost_history.ps1 -resourceId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/xxxxxxxx/providers/microsoft.compute/disks/xxxxxxx"
    .\get_cost_history.ps1 -resourceId @("Id1", "Id2", ...)
    .\get_cost_history.ps1 -resourceId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/xxxxxxxx/providers/microsoft.compute/disks/xxxxxxx" -startDate "2023-01-01" -endDate "2023-06-30"

.NOTES
    Documentation links:
    https://learn.microsoft.com/en-us/rest/api/cost-management/query/usage
#>

param (
    [Parameter(Mandatory=$true)][string[]]$resourceId,
    [string]$startDate = (Get-Date).AddMonths(-6).ToString("yyyy-MM-01"),               # the first day of the month 6 months ago
    [string]$endDate = (Get-Date).AddDays(-1 * (Get-Date).Day).ToString("yyyy-MM-dd")   # the last day of the previous month
)

# Timeframe
# Supported types are BillingMonthToDate, Custom, MonthToDate, TheLastBillingMonth, TheLastMonth, WeekToDate
$timeframe = "Custom"            

# Granularity
# Supported types are Daily and Monthly so far. Omit just to get the total cost.
$granularity = "Monthly"         

# Type
# Supported types are Usage (deprecated), ActualCost, and AmortizedCost
# https://stackoverflow.com/questions/68223909/in-the-azure-consumption-usage-details-api-what-is-the-difference-between-the-m
$type = "AmortizedCost"          

# Scope
<# Scope can be:
https://learn.microsoft.com/en-us/powershell/module/az.costmanagement/invoke-azcostmanagementquery?view=azps-10.1.0#-scope

Subscription scope       : /subscriptions/{subscriptionId}
Resource group scope     : /subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}
Billing account scope    : /providers/Microsoft.Billing/billingAccounts/{billingAccountId}
Department scope         : /providers/Microsoft.Billing/billingAccounts/{billingAccountId}/departments/{departmentId}
Enrollment account scope : /providers/Microsoft.Billing/billingAccounts/{billingAccountId}/enrollmentAccounts/{enrollmentAccountId}
Management group scope   : /providers/Microsoft.Management/managementGroups/{managementGroupId}
Billing profile scope    : /providers/Microsoft.Billing/billingAccounts/{billingAccountId}/billingProfiles/{billingProfileId}
Invoice section scope    : /providers/Microsoft.Billing/billingAccounts/{billingAccountId}/billingProfiles/{billingProfileId}/invoiceSections/{invoiceSectionId}
Partner scope            : /providers/Microsoft.Billing/billingAccounts/{billingAccountId}/customers/{customerId}

For a customer with a Microsoft Enterprise Agreement or Microsoft Customer Agreement, billing account scope is recommended. #>
$scope = "/subscriptions/628b6cdb-10b6-4463-a581-04a2c18505fd"

# For testing purposes the resource group of the first resource ID could be used.
#$scope = ""
#$resourceId[0].Split("/")[1..4] | ForEach-Object {$scope += "/$_"}

# Grouping
<# Dimensions for grouping the output. Valid dimensions for grouping are:

AccountName
BenefitId
BenefitName
BillingAccountId
BillingMonth
BillingPeriod
ChargeType
ConsumedService
CostAllocationRuleName
DepartmentName
EnrollmentAccountName
Frequency
InvoiceNumber
MarkupRuleName
Meter
MeterCategory
MeterId
MeterSubcategory
PartNumber
PricingModel
PublisherType
ReservationId
ReservationName
ResourceGroup
ResourceGroupName
ResourceGuid
ResourceId
ResourceLocation
ResourceType
ServiceName
ServiceTier
SubscriptionId
SubscriptionName
#>
$grouping = @(
    @{
        type = "Dimension"
        name = "ResourceId"
    }
)

# Aggregation
# Supported types are Sum, Average, Minimum, Maximum, Count, and Total.
$aggregation = @{
    PreTaxCost = @{
        function = "Sum"
        name = "PreTaxCost"
    }
}

# Filter
# In this script we use dimension resource ID as the filter
$filter = @{
    dimensions = @{
        name = "ResourceId"
        operator = "In"
        values = @($resourceId)
    }
}

# Create the body of the request
$body = @{
    type = $type
    timeframe = $timeframe
    timePeriod = @{
        from = $startDate
        to = $endDate
    }
    dataset = @{
        granularity = $granularity
        grouping = $grouping
        aggregation = $aggregation
        filter = $filter
    }
} | ConvertTo-Json -Depth 10

$uri = "https://management.azure.com$scope/providers/Microsoft.CostManagement/query?api-version=2023-03-01"

# Get the access token for passing in the header
$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
   'Content-Type'='application/json'
   'Authorization'='Bearer ' + $token.AccessToken
}

$queryResult = Invoke-RestMethod -Uri $uri -Method Post -Headers $authHeader -Body $body

# Convert the query result into a table
$table = @()
for ($i = 0; $i -lt $queryResult.properties.rows.Count; $i++) {
    $row = [PSCustomObject]@{}
    for ($j = 0; $j -lt $queryResult.properties.columns.Count; $j++) {
        $row | Add-Member -MemberType NoteProperty -Name $queryResult.properties.columns.name[$j] -Value $queryResult.properties.rows[$i][$j]
    }
    $table += $row
}

$table | Format-Table -AutoSize
