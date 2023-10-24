# Set the Execution policy for the current session
# Set-ExecutionPolicy -ExecutionPolicy ByPass -Scope Process

param (
    [Parameter(Mandatory = $true)]
    [string]
    $storageAccKey
)

$containerName = 'lcmtest1'
$storageAccName = 'stglcmtestsc1'

# Create a context object using storage account name and key
$ctx = New-AzStorageContext -StorageAccountName $storageAccName -StorageAccountKey $storageAccKey

# Get blobs
$blobs = Get-AzStorageBlob -Container $containerName -Context $ctx

# Cycle through blobs and get last accessed time
$table = @()
foreach ($blob in $blobs) {
    $blobName = $blob.Name
    $blob = Get-AzStorageBlob -Blob $blobName -Container $containerName -Context $ctx
    $properties = $blob.BlobClient.GetProperties()
    $table += [pscustomobject]@{
        BlobName = $blobName
        LastAccessed = $properties.Value.LastAccessed
    }
}
$table | Format-Table
