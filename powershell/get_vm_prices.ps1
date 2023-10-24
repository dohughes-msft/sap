<#
.SYNOPSIS
    Script to query the Azure Price API for virtual machine prices and output the results into separate CSV files for PAYG, RI and ASP
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices
#>

$baseUri = "https://prices.azure.com/api/retail/prices?api-version=2023-01-01-preview"

#$filterString = '$filter=serviceName eq ''Virtual Machines'' and armRegionName eq ''swedencentral'' and armSkuName eq ''Standard_M416s_8_v2'''
#$filterString = '$filter=serviceName eq ''Virtual Machines'' and armRegionName eq ''swedencentral'' and priceType eq ''Reservation'''
#$filterString = '$filter=serviceName eq ''Virtual Machines'' and armRegionName eq ''westeurope'' and armSkuName eq ''Standard_D32a_v4'''
$filterString = '$filter=currencyCode eq ''USD'' and serviceName eq ''Virtual Machines'' and armRegionName eq ''westeurope'' and (priceType eq ''Reservation'' or priceType eq ''Consumption'')'

# Useful for debugging - process more than one page of results?
$multiPage = $true

$uri = "$baseUri&$filterString"
$table = @()

# Perform the initial call to get the first page
$queryResult = Invoke-RestMethod -Uri $uri -Method Get
$resultCount = $queryResult.Items.Count
Write-Host "$resultCount rows fetched."
$table += $queryResult.Items

# If there are more pages, get them
if ($multiPage) {
    while ($null -ne $queryResult.NextPageLink) {
        $queryResult = Invoke-RestMethod -Uri $queryResult.NextPageLink -Method Get
        $resultCount += $queryResult.Items.Count
        Write-Host "$resultCount rows fetched."
        $table += $queryResult.Items
    }
}

# The table object that we get unfortunately contains sub-objects (rows) with different properties depending on the price type (PAYG, Reservation, Savings Plan)
# We need to explicitly specify the properties we are interested in to get the correct output to export

$table | Where-Object type -eq "Consumption" | Select-Object -Property skuId, retailPrice, productName, armSkuName, skuName | Export-Csv -Path "payg.csv"
$table | Where-Object type -eq "Reservation" | Select-Object -Property skuId, reservationTerm, retailPrice, productName, armSkuName, skuName | Export-Csv -Path "reservations.csv"
$table | Where-Object savingsPlan -ne $null  | Select-Object -Property skuId, armSkuName, productName, skuName -ExpandProperty savingsPlan | Export-Csv -Path "savingsplans.csv"
