$hyperVDataDir = "G:\HyperV"

# Create a Hyper-V switch
New-VMSwitch -SwitchName "NATSwitch" -SwitchType Internal
New-NetIPAddress -IPAddress 192.168.1.1 -PrefixLength 24 -InterfaceAlias "vEthernet (NATSwitch)"
New-NetNat -Name NATNetwork -InternalIPInterfaceAddressPrefix 192.168.1.0/24

# Download 7zip
$7zipUrl = "https://7-zip.org/a/7zr.exe"
$7zipExe = "D:\7zr.exe"
$zipFile = "D:\VMs.zip"
Invoke-WebRequest $7zipUrl -OutFile $7zipExe

# Download AzCopy
$azCopyUrl = "https://aka.ms/downloadazcopy-v10-windows"
$azCopyZipfile = "D:\AzCopy.zip"
$azCopyLocation = "D:\AzCopy"
$azCopyExe = "D:\azcopy.exe"
mkdir $azCopyLocation
Invoke-WebRequest $azCopyUrl -OutFile $azCopyZipfile
Expand-Archive -Path $azCopyZipfile -DestinationPath $azCopyLocation
Get-ChildItem -Path $azCopyLocation -Recurse azcopy.exe | Move-Item -Destination $azCopyExe

# Pull VM zip from blob storage
$blob = "https://asrdemone.blob.core.windows.net/asrdemo/VMs.zip"
& $azCopyExe copy $blob $zipFile

# Unzip the files
& $7zipExe x -bsp1 -o"$hyperVDataDir" $zipFile

# Import the VMs
$vms = Get-ChildItem -Path $hyperVDataDir -Recurse *.vmcx
foreach ($vm in $vms) {
    $vmIdFile = $vm.DirectoryName + '\' + $vm.Name
    Write-Host "Importing VM with configuration file $vmIdFile"
    Import-VM -Path $vmIdFile
}
