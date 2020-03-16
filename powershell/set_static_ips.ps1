<#
.SYNOPSIS
    Set all IP configurations for all NICs in a resource group to be static
.EXAMPLE
    PS C:\> set_static_ips.ps1 -resourceGroupName mytestrg
.INPUTS
    -resourceGroupName <group> : the resource group in which to operate
.OUTPUTS
    None
.NOTES
    None
#>

param(
    [Parameter(Mandatory=$true)][string]$resourceGroupName
)

$nics = Get-AzNetworkInterface -ResourceGroupName $resourceGroupName

Write-Output "Initial status of NICs in resource group $resourceGroupName`:"
$nics | Select-Object @{n='NIC name';e={$_.Name}} -ExpandProperty IpConfigurations | Select-Object "NIC name", PrivateIpAllocationMethod | Format-Table

foreach($nic in $nics) {
    $flag=$false
    foreach($ipConfig in $nic.IpConfigurations) {
        if ($ipConfig.PrivateIpAllocationMethod -eq "Dynamic") {
            $ipConfig.PrivateIpAllocationMethod = "Static"
            $flag=$true
        }
    }
    if ($flag -eq $true) {
        Write-Output "Changing IP configuration(s) from Dynamic to Static for $($nic.Name)..."
        $nic | Set-AzNetworkInterface | Out-Null
    }
}

Write-Output "`nFinal status of NICs in resource group $resourceGroupName`:"
Get-AzNetworkInterface -ResourceGroupName $resourceGroupName | Select-Object @{n='NIC name';e={$_.Name}} -ExpandProperty IpConfigurations | Select-Object "NIC name", PrivateIpAllocationMethod | Format-Table
