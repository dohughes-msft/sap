#$uri = "https://prices.azure.com/api/retail/prices?api-version=2023-01-01-preview"
#$uri = "https://prices.azure.com/api/retail/prices?´$filter=serviceName eq 'Virtual Machines' and armRegionName eq 'eastus' and priceType eq 'Consumption' and termType eq '1 Year'"

$uri = "https://prices.azure.com/api/retail/prices?api-version=2023-01-01-preview&`$filter=serviceName eq 'Virtual Machines' and armRegionName eq 'swedencentral' and armSkuName eq 'Standard_M416s_8_v2'"

$response = Invoke-RestMethod -Uri $uri -Method Get

$response.Items

$response.items | Select-Object -Property id, productName, meterName, unitOfMeasure, retailPrice, reservationTerm
