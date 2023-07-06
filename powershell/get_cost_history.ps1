<#
.SYNOPSIS
    Take a given resource ID and return the cost history for that resource. For this we use the Microsoft.CostManagement provider
    of the resource group containing the resource.
    Requires Az.CostManagement module

.PARAMETER ParameterName
    $resourceID (mandatory) : The resource ID of the resource to be examined
    $startDate  (optional)  : The start date of the period to be examined (default is the first day of the month, 6 months ago)
    $endDate    (optional)  : The end date of the period to be examined (default is the last day of the previous month)

.INPUTS
    None

.OUTPUTS
    A table showing the cost history of the given resource over the requested period

.EXAMPLE
    .\get_cost_history.ps1 -resourceId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/xxxxxxxx/providers/microsoft.compute/disks/xxxxxxx"
    .\get_cost_history.ps1 -resourceId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourcegroups/xxxxxxxx/providers/microsoft.compute/disks/xxxxxxx" -startDate "2023-01-01" -endDate "2023-06-30"

.NOTES
    Documentation links:
    https://learn.microsoft.com/en-us/rest/api/cost-management/query/usage
    https://learn.microsoft.com/en-us/powershell/module/az.costmanagement/invoke-azcostmanagementquery
#>

param (
    [Parameter(Mandatory=$true)][string]$resourceId,
    [string]$startDate = (Get-Date).AddMonths(-6).ToString("yyyy-MM-01"),               # the first day of the month 6 months ago
    [string]$endDate = (Get-Date).AddDays(-1 * (Get-Date).Day).ToString("yyyy-MM-dd")   # the last day of the previous month
)

$timeframe = "Custom"            # Supported types are BillingMonthToDate, Custom, MonthToDate, TheLastBillingMonth, TheLastMonth, WeekToDate
$granularity = "Monthly"         # Supported types are Daily and Monthly so far. Omit just to get the total cost.
$type = "AmortizedCost"          # Supported types are Usage (deprecated), ActualCost, and AmortizedCost
# https://stackoverflow.com/questions/68223909/in-the-azure-consumption-usage-details-api-what-is-the-difference-between-the-m

$grouping = @(
    @{
        type = "Dimension"
        name = "ResourceId"
    }
)

<# Valid dimensions for grouping are:
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

$aggregation = @{
    PreTaxCost = @{
        type = "Sum"
        name = "PreTaxCost"
    }
}

# For the purposes of this script we will set the scope to be the resource group, which we can extract from the resource ID.
$resourceId.Split("/")[1..4] | ForEach {$scope += "/$_"}

# Create the filter object based on the resource ID
$dimensions = New-AzCostManagementQueryComparisonExpressionObject -Name 'ResourceId' -Value $resourceId -Operator 'In'
$filter = New-AzCostManagementQueryFilterObject -Dimensions $dimensions
$queryResult = Invoke-AzCostManagementQuery `
    -Scope $scope `
    -Timeframe $timeframe `
    -Type $type `
    -DatasetFilter $filter `
    -TimePeriodFrom $startDate `
    -TimePeriodTo $endDate `
    -DatasetGrouping $grouping `
    -DatasetAggregation $aggregation `
    -DatasetGranularity $granularity
#-Debug

# Convert the query result into a table
$table = @()
for ($i = 0; $i -lt $queryResult.Row.Count; $i++) {
    $row = [PSCustomObject]@{}
    for ($j = 0; $j -lt $queryResult.Column.Count; $j++) {
        $row | Add-Member -MemberType NoteProperty -Name $queryResult.Column.Name[$j] -Value $queryResult.Row[$i][$j]
    }
    $table += $row
}

$table | Format-Table -AutoSize
