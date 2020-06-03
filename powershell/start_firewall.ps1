<#
.SYNOPSIS
    Start a currently deprovisioned Azure Firewall
.EXAMPLE
    PS C:\> start_firewall.ps1 -resourceGroup myrg -firewallName myfirewall -vnetName myvnet -pipName fwpip1
    Start the firewall named myfirewall in resource group myrg with the give VNET and public IP address
.INPUTS
    resourceGroup : Name of the resource group containing the firewall, VNET, and public IP address
    firewallName  : Name of the firewall
    vnetName      : Name of the VNET
    pipName       : Name of the public IP address
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

param (
    [string]$resourceGroup="hubspoke-rg3",
    [string]$firewallName="firewall-1",
    [string]$vnetName="hub-vnet",
    [string]$pipName="firewall-1-pip"
)

$azfw = Get-AzFirewall -Name $firewallName -ResourceGroupName $resourceGroup
$vnet = Get-AzVirtualNetwork -ResourceGroupName $resourceGroup -Name $vnetName
$publicip = Get-AzPublicIpAddress -Name $pipName -ResourceGroupName $resourceGroup
$azfw.Allocate($vnet,$publicip)
Set-AzFirewall -AzureFirewall $azfw