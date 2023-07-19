# Format the data disk
$hyperVDataDir = "G:\HyperV"

$diskNumber = (Get-Disk | Where-Object PartitionStyle -eq "RAW").Number
Initialize-Disk -Number $diskNumber -PartitionStyle MBR -Confirm:$false
New-Partition -DiskNumber $diskNumber -UseMaximumSize -IsActive | Format-Volume -Filesystem NTFS -NewFileSystemLabel "HyperVData" -Confirm:$false
Set-Partition -DiskNumber $diskNumber -PartitionNumber 1 -NewDriveLetter G
mkdir $hyperVDataDir

# Set the server's IP to be static - will trigger a drop in connectivity

$addressFamily = "IPv4"
$ipAddress = "10.0.0.4"
$gateway = "10.0.0.1"
$prefixLength = 24
$dnsServer = "168.63.129.16"

$adapter = Get-NetAdapter | Where-Object Name -eq "Ethernet"

if (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
    $adapter | Remove-NetIPAddress -AddressFamily $addressFamily -Confirm:$false
   }

if (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
    $adapter | Remove-NetRoute -AddressFamily $addressFamily -Confirm:$false
   }

$adapter | New-NetIPAddress -AddressFamily $addressFamily -IPAddress $ipAddress -PrefixLength $prefixLength -DefaultGateway $gateway
$adapter | Set-DnsClientServerAddress -ServerAddresses $dnsServer

# Install DNS
Install-WindowsFeature -Name DNS -IncludeManagementTools
# Set Azure DNS as the default forwarder
$Forwarders = "168.63.129.16"   # Azure DNS
Set-DnsServerForwarder -IPAddress $Forwarders

# Install Hyper-V - will trigger a restart
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart
