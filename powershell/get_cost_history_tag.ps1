<#
.SYNOPSIS
    Take a tag and a collection of values and return the cost history for matching resources. For this we use the Microsoft.CostManagement provider
    of the resource group containing the resource.
    Requires Az.CostManagement module

.PARAMETER ParameterName
    $tagName      (mandatory) : The name of the tag to be filtered on
    $tagValues[]  (mandatory) : Values of the tag to be filtered on
    $startDate    (optional)  : The start date of the period to be examined (default is the first day of the month, 6 months ago)
    $endDate      (optional)  : The end date of the period to be examined (default is the last day of the previous month)

.INPUTS
    None

.OUTPUTS
    A table showing the cost history of resources matching the given tag name and values over the requested period

.EXAMPLE
    .\get_cost_history.ps1 -tagName "Environment" -tagValues @("Dev", "Test")
    .\get_cost_history.ps1 -tagName "Environment" -tagValues @("Dev", "Test") -startDate "2023-01-01" -endDate "2023-06-30"

.NOTES
    Documentation links:
    https://learn.microsoft.com/en-us/rest/api/cost-management/query/usage
#>

param (
    [Parameter(Mandatory=$true)][string]$tagName,
    [Parameter(Mandatory=$true)][string[]]$tagValues,
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
$scope = "/subscriptions/f3bd1cf9-6b3f-4fda-b3f9-83e9467674cf"

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

# Get the access token for passing in the header
$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
   'Content-Type'='application/json'
   'Authorization'='Bearer ' + $token.AccessToken
}

# Filter
# In this script we use the provided tag as a filter
$tags = New-AzCostManagementQueryComparisonExpressionObject -Name $tagName -Value $tagValues -Operator 'In'
$filter = New-AzCostManagementQueryFilterObject -Tag $tags

$queryResult = Invoke-AzCostManagementQuery `
    -Scope $scope `
    -Timeframe $timeframe `
    -Type $type `
    -DatasetFilter $filter `
    -TimePeriodFrom $startDate `
    -TimePeriodTo $endDate `
    -DatasetGrouping $grouping `
    -DatasetAggregation $aggregation `
    -DatasetGranularity $granularity `
    -Debug

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
