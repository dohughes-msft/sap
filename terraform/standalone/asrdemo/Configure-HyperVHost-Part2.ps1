$hyperVDataDir = "G:\HyperV"

# Create a Hyper-V switch
Write-Host "Creating NAT switch for Hyper-V..."
New-VMSwitch -SwitchName "NATSwitch" -SwitchType Internal
New-NetIPAddress -IPAddress 192.168.1.1 -PrefixLength 24 -InterfaceAlias "vEthernet (NATSwitch)"
New-NetNat -Name NATNetwork -InternalIPInterfaceAddressPrefix 192.168.1.0/24

# Download 7zip
Write-Host "Fetching 7zip command line executable..."
$7zipUrl = "https://7-zip.org/a/7zr.exe"
$7zipExe = "D:\7zr.exe"
$zipFile = "D:\VMs.zip"
Invoke-WebRequest $7zipUrl -OutFile $7zipExe

# Download AzCopy
Write-Host "Fetching AzCopy..."
$azCopyUrl = "https://aka.ms/downloadazcopy-v10-windows"
$azCopyZipfile = "D:\AzCopy.zip"
$azCopyLocation = "D:\AzCopy"
$azCopyExe = "D:\azcopy.exe"
mkdir $azCopyLocation
Invoke-WebRequest $azCopyUrl -OutFile $azCopyZipfile
Expand-Archive -Path $azCopyZipfile -DestinationPath $azCopyLocation
Get-ChildItem -Path $azCopyLocation -Recurse azcopy.exe | Move-Item -Destination $azCopyExe

# Pull VM zip from blob storage
Write-Host "Fetching VM images from storage..."
$blob = "https://asrdemone.blob.core.windows.net/asrdemo/VMs.zip?sp=r&st=2023-07-21T12:31:17Z&se=2025-12-31T21:31:17Z&spr=https&sv=2022-11-02&sr=c&sig=lPhtEf2YjbZjH7NWs7K6hhoDLBxVKN9XeAreSBJqRj8%3D"
& $azCopyExe copy $blob $zipFile

# Unzip the files
Write-Host "Unzipping VM images..."
& $7zipExe x -bsp1 -o"$hyperVDataDir" $zipFile

# Import the VMs
Write-Host "Importing virtual machines..."
$vms = Get-ChildItem -Path $hyperVDataDir -Recurse *.vmcx
foreach ($vm in $vms) {
    $vmIdFile = $vm.DirectoryName + '\' + $vm.Name
    Write-Host "Importing VM with configuration file $vmIdFile"
    Import-VM -Path $vmIdFile
}

# Start the VMs
Write-Host "Starting virtual machines..."
Get-VM | Start-VM

# Download the site recovery installer for Hyper-V
Write-Host "Downloading Hyper-V site recovery provider..."
$hyperVInstaller = "https://aka.ms/downloaddra_ne"
$tempDrive = "D:\AzureSiteRecoveryProvider.exe"
Invoke-WebRequest $hyperVInstaller -OutFile $tempDrive
