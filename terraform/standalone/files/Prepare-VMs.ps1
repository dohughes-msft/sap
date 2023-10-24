# This script is used to export, zip and upload the VMs again in case any changes are made

# Export VMs
$exportPath = "D:\Export"
Get-VM | Export-VM -Path $exportPath

# Create archive

# Get 7zip
$7zipUrl = "https://7-zip.org/a/7zr.exe"
$7zipExe = "D:\7zr.exe"
$zipFile = "D:\VMs.zip"
Invoke-WebRequest $7zipUrl -OutFile $7zipExe

# Zip the VMs into a single file
& $7zipExe a -bsp1 $zipFile $exportPath\*

# Download AzCopy
$azCopyUrl = "https://aka.ms/downloadazcopy-v10-windows"
$azCopyZipfile = "D:\AzCopy.zip"
$azCopyLocation = "D:\AzCopy"
$azCopyExe = "D:\azcopy.exe"
mkdir $azCopyLocation
Invoke-WebRequest $azCopyUrl -OutFile $azCopyZipfile
Expand-Archive -Path $azCopyZipfile -DestinationPath $azCopyLocation
Get-ChildItem -Path $azCopyLocation -Recurse azcopy.exe | Move-Item -Destination $azCopyExe

# Upload the zipped VMs to blob storage
$container = "<URL including SAS key>"
& $azCopyExe copy $zipFile $container
