<#
.SYNOPSIS
    Short description
.DESCRIPTION
    Long description
.EXAMPLE
    PS C:\> <example usage>
    Explanation of what the example does
.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    General notes
#>

# General parameters
$azcopy = "C:\Users\dohughes\azcopy.exe"

# Source information
$sourceResourceGroup = "move-rg1"
$sourceVmName = "movevm1"
$blobContainerName = "migration"

# Target information
$targetRegion = "northeurope"
$targetVmResourceGroup = "move-rg1-new"
$targetVnet = "moved-vnet"
$targetStorageAccountResourceGroup = "sap-shared-northeurope-rg1"
$targetStorageAccount = "sapnortheurope"

$subnetMappingJson = '[
    {
        "oldSubnet": "/subscriptions/3e51b8f1-b856-4896-9a90-50ac02c27cf1/resourceGroups/move-rg1/providers/Microsoft.Network/virtualNetworks/move-rg1-vnet/subnets/default",
        "newSubnet": "/subscriptions/3e51b8f1-b856-4896-9a90-50ac02c27cf1/resourceGroups/move-rg1-new/providers/Microsoft.Network/virtualNetworks/migrationvnet/subnets/default"
    }
]'
$subnetMapping = $subnetMappingJson | ConvertFrom-Json

function mapSubnet($subnetId) {
    return ($subnetMapping | Where-Object { $_.oldSubnet -eq $subnetId }).newSubnet
}

$targetStorageAccountId = (Get-AzStorageAccount -Name $targetStorageAccount -ResourceGroupName $targetStorageAccountResourceGroup).Id
$sourceVm = Get-AzVm -Name $sourceVmName -ResourceGroupName $sourceResourceGroup
$targetStorageAccountKey = (Get-AzStorageAccountKey -Name $targetStorageAccount -ResourceGroupName $targetStorageAccountResourceGroup).value[0]
$targetStorageContext = New-AzStorageContext -StorageAccountName $targetStorageAccount -StorageAccountKey $targetStorageAccountKey -ErrorAction stop
$targetSas = New-AzStorageContainerSASToken -Container $blobContainerName -Permission rwd -Context $targetStorageContext

# Create the configuration for the new VM
$newVm = New-AzVMConfig -VMName $sourceVmName -VMSize $sourceVm.HardwareProfile.VmSize

# Clone the OS disk
$osDisk = Get-AzDisk -ResourceGroupName $sourceResourceGroup -Name $sourceVm.StorageProfile.OsDisk.Name
$diskAccess = Grant-AzDiskAccess -ResourceGroupName $sourceResourceGroup -DiskName $osDisk.Name -DurationInSecond 3600 -Access Read -ErrorAction stop
& $azcopy copy "$($diskAccess.AccessSAS)" "https://$targetStorageAccount.blob.core.windows.net/$blobContainerName/$($osDisk.Name)$($targetSas)"
$diskuri = "https://$($targetStorageAccount).blob.core.windows.net/$($blobContainerName)/$($osDisk.Name)"
$diskConfig = New-AzDiskConfig -AccountType $disk.Sku.Name -Location $targetRegion -CreateOption Import -StorageAccountId $targetStorageAccountId -SourceUri $diskuri -OsType $osDisk.OsType
$newDisk = New-AzDisk -Disk $diskConfig -ResourceGroupName $targetVmResourceGroup -DiskName $osDisk.Name -ErrorAction stop
if ($disk.OsType -eq "Linux") {
    Set-AzVMOSDisk -VM $newVm -CreateOption Attach -ManagedDiskId $newDisk.Id -Name $newDisk.Name -Linux | Out-Null
} else {
    Set-AzVMOSDisk -VM $newVm -CreateOption Attach -ManagedDiskId $newDisk.Id -Name $newDisk.Name -Windows | Out-Null
}

# Clone the data disks
$dataDisks = Get-AzDisk -ResourceGroupName $sourceResourceGroup | Where-Object ManagedBy -eq $sourceVm.Id | Where-Object Id -ne $osDisk.Id

foreach ($dataDisk in $dataDisks) {
    # Get the LUN number and caching setting from the original VM object
    $lun = ($sourceVm.StorageProfile.DataDisks | Where-Object Name -eq $dataDisk.Name).Lun
    $caching = ($sourceVm.StorageProfile.DataDisks | Where-Object Name -eq $dataDisk.Name).Caching
    $diskAccess = Grant-AzDiskAccess -ResourceGroupName $sourceResourceGroup -DiskName $dataDisk.Name -DurationInSecond 3600 -Access Read -ErrorAction stop
    & $azcopy copy "$($diskAccess.AccessSAS)" "https://$targetStorageAccount.blob.core.windows.net/$blobContainerName/$($dataDisk.Name)$($targetSas)"
    $diskuri = "https://$($targetStorageAccount).blob.core.windows.net/$($blobContainerName)/$($dataDisk.Name)"
    $diskConfig = New-AzDiskConfig -AccountType $dataDisk.Sku.Name -Location $targetRegion -CreateOption Import -StorageAccountId $targetStorageAccountId -SourceUri $diskuri
    $newDisk = New-AzDisk -Disk $diskConfig -ResourceGroupName $targetVmResourceGroup -DiskName $dataDisk.Name -ErrorAction stop
    Add-AzVMDataDisk -VM $newVm -Name $dataDisk.Name -ManagedDiskId $newDisk.Id -Caching $caching -Lun $lun -DiskSizeInGB $dataDisk.DiskSizeGB -CreateOption Attach | Out-Null
}

# Deprecated - use azcopy instead
#        $vhdname = $disk.Name
#        Start-AzStorageBlobCopy -AbsoluteUri $diskAccess.AccessSAS -DestContainer $blobContainerName -DestContext $targetStorageContext -DestBlob "$($vhdname).vhd" -Force -ErrorAction stop
#        Get-AzStorageBlobCopyState -Blob "$($vhdname).vhd" -Container $blobContainerName -Context $targetStorageContext -WaitForComplete

# Clone the NICs

$nics = Get-AzNetworkInterface -ResourceGroupName $sourceResourceGroup | Where-Object Id -in $sourceVm.NetworkProfile.NetworkInterfaces.Id

# Clone the primary NIC
$primaryNic = $nics | Where-Object Primary -eq "True"
$secondaryNics = $nics | Where-Object Primary -ne "True"

$primaryIpConfig = $primaryNic.IpConfigurations | Where-Object { $_.Primary -eq "True" }
$newSubnetId = mapSubnet($primaryIpConfig.Subnet.Id)
$newSubnet = Get-AzVirtualNetworkSubnetConfig -resourceId $newSubnetId
$newIpConfig = New-AzNetworkInterfaceIpConfig -Name $primaryIpConfig.Name -Subnet $newSubnet
$newNic = New-AzNetworkInterface -Name $primaryNic.Name -ResourceGroupName $targetVmResourceGroup -Location $targetRegion -IpConfiguration $newIpConfig
foreach ($ipConfig in $primaryNic.IpConfigurations) {
    if ($ipConfig.Primary -ne "True") {
        $newSubnetId = mapSubnet($ipConfig.Subnet.Id)
        $newSubnet = Get-AzVirtualNetworkSubnetConfig -resourceId $newSubnetId
        Add-AzNetworkInterfaceIpConfig -Name $ipConfig.Name -NetworkInterface $newNic -Subnet $newSubnet
        $newNic | Set-AzNetworkInterface
    }
}
Add-AzVMNetworkInterface -VM $newVm -Id $newNic.Id -Primary

# Clone the other NICs

foreach ($secondaryNic in $secondaryNics) {
    # Clone the NIC with the primary IP configuration
    $primaryIpConfig = $secondaryNic.IpConfigurations | Where-Object { $_.Primary -eq "True" }
    $newSubnetId = mapSubnet($primaryIpConfig.Subnet.Id)
    $newSubnet = Get-AzVirtualNetworkSubnetConfig -resourceId $newSubnetId
    $newIpConfig = New-AzNetworkInterfaceIpConfig -Name $primaryIpConfig.Name -Subnet $newSubnet
    $newNic = New-AzNetworkInterface -Name $secondaryNic.Name -ResourceGroupName $targetVmResourceGroup -Location $targetRegion -IpConfiguration $newIpConfig
    foreach ($ipConfig in $secondaryNic.IpConfigurations) {
        if ($ipConfig.Primary -ne "True") {
            $newSubnetId = mapSubnet($ipConfig.Subnet.Id)
            $newSubnet = Get-AzVirtualNetworkSubnetConfig -resourceId $newSubnetId
            Add-AzNetworkInterfaceIpConfig -Name $ipConfig.Name -NetworkInterface $newNic -Subnet $newSubnet
            $newNic | Set-AzNetworkInterface
        }
    }
    Add-AzVMNetworkInterface -VM $newVm -Id $newNic.Id
}

# Add the primary NIC
#Add-AzVMNetworkInterface -VM $newVm -Id $primaryNicId -Primary | Out-Null

Write-Verbose "Deploying new VM instance."
# Recreate the VM
New-AzVM -ResourceGroupName $targetVmResourceGroup -Location $targetRegion -VM $newVm
