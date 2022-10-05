# Backup and restore of Azure Files NFS
Azure Files NFS is not yet integrated into Azure Backup. The scripts here can be used to perform basic backup/restore of Azure Files NFS shares to blob storage.

## About blob storage

Azure blob storage is designed for high-speed ingestion and restore of massive amounts of data to a single object. It does this very well, but at the expense of metadata operations, which take longer. Fewer, larger files will therefore be faster to back up and restore than a large number of smaller files. Your mileage may vary so be sure to test both backup and restore.

Blob storage does not support permissions or symbolic links so this metadata is handled specially.

**DISCLAIMER: These scripts are not tested for all possible use cases and are to used AT YOUR OWN RISK.**

## Notes and requirements

1. For maximum data protection, enable blob versioning and soft delete on the target storage account.
2. The scripts must be executed on a VM host with the NFS file share mounted. Azure Files NFS shares are only accessible from within the Azure VNET.
3. [AzCopy](https://docs.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?toc=/azure/storage/blobs/toc.json) must be installed on the host.
4. Define the shared access signature (SAS) in environment variable `$BLOBSAS` before executing the scripts.
5. Adjust the other variables defined within the scripts to suit your environment.
6. Always restore to a new location first, and check that the result is as expected before overwriting existing shares.
