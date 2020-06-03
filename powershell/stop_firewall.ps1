<#
.SYNOPSIS
    Stop (deprovision) an existing Azure Firewall
.EXAMPLE
    PS C:\> stop_firewall.ps1 -resourceGroup myrg -name myfirewall
    Stop the firewall named myfirewall in resource group myrg
.INPUTS
    resourceGroup : Name of the resource group containing the firewall
    name          : Name of the firewall
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

param (
    [string]$resourceGroup="hubspoke-rg3",
    [string]$name="firewall-1"
)

$azfw = Get-AzFirewall -Name $name -ResourceGroupName $resourceGroup
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw