$vaultName = "asrdemo-rsv"
$resourceGroupName = "asrdemo-azure-rg1"
$vault = Get-AzRecoveryServicesVault -Name $vaultName -ResourceGroupName $vaultRG
Set-AzRecoveryServicesAsrVaultContext -Vault $vault
$SiteName = "HypervSiteDemo"
New-AzRecoveryServicesAsrFabric -Name $SiteName -Type HyperVSite
