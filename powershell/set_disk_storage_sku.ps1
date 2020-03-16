<#
.SYNOPSIS
    Change all disks to a designated storage SKU for all VMs in a resource group or a single VM
.EXAMPLE
    Example 1: Change all disks on all VMs in resource group App1RG to Standard HDD:    
        PS C:\> set_storage_sku.ps1 -resourceGroupName App1RG -sku Standard_LRS
    Example 2: Change all disks on VM AppServer1 in resource group App4RG to Premium SSD:
        PS C:\> set_storage_sku.ps1 -resourceGroupName App4RG -sku Premium_LRS -vmName AppServer1
.INPUTS
    -resourceGroupName <group> : the resource group containing the VM(s) to operate on
    -sku <sku>                 : the storage SKU - Standard_LRS, StandardSSD_LRS, Premium_LRS, UltraSSD_LRS
    -vmName <vm>               : (optional) the VM on which to operate - default is all VMs in the resource group
.OUTPUTS
    The list of disks that had their SKU changed.
.NOTES
    Specify the resource group containing the virtual machines, not the disks. VMs must be deallocated.
#>

param(
    [Parameter(Mandatory=$true)][string]$resourceGroupName,
    [Parameter(Mandatory=$true)][ValidateSet('Standard_LRS', 'StandardSSD_LRS', 'Premium_LRS', 'UltraSSD_LRS')][string]$sku,
    [string]$vmName
)

if ($PSBoundParameters.ContainsKey('vmName')) {
    $vmIdList = (Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Compute/virtualMachines -Name $vmName).ResourceId
} else {
    $vmIdList = (Get-AzResource -ResourceGroupName $resourceGroupName -ResourceType Microsoft.Compute/virtualMachines).ResourceId
}

$disks = Get-AzDisk | Where-Object {$_.ManagedBy -in $vmIdList -and $_.Sku.Name -ne $sku}
foreach($disk in $disks) {
    $disk.sku.Name = $sku
}

$output = $disks | Update-AzDisk

Write-Output "`nThe following disks were changed to SKU: $sku"
$output | Select-Object @{n='Resource group';e={$_.ResourceGroupName}}, @{n='Virtual machine';e={$_.ManagedBy -replace '.*/'}}, @{n='Disk';e={$_.Id -replace '.*/'}} | Format-Table -AutoSize
