$rgName = "sftp-rg9"
$loc = "westus2"
$containerName = "sftp"
$image = "atmoz/sftp:latest"
$users  = "sftpuser1:sftppass1:1001 "
$users += "sftpuser2:sftppass2:1002 "
$users += "sftpuser3:sftppass3:1003 "
$envVar = @{}
$envVar.Add('SFTP_USERS', $users)
#$envVar.Add('SFTP_USERS', 'sftpuser1:sftppass1:::/share/sftpuser1')

$storageAccountName = "sftpaccount1"
$shareName = "sftpshare1"
$key = "punZbW3tGK+09BlGyzMlEb567i62vmaSYD143+Ep37BuREpvVcIq6lk7Xz0ZYz8Vns/N4XKr31DyebevPAPfag=="
$encryptedKey = ConvertTo-SecureString $key -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($storageAccountName, $encryptedKey)

New-AzResourceGroup -Name $rgName -Location $loc
New-AzContainerGroup -ResourceGroupName $rgName `
                     -Name $containerName `
                     -Image $image `
                     -MemoryInGB 1 `
                     -Cpu 1 `
                     -Port 22 `
                     -IpAddressType Public `
                     -EnvironmentVariable $envVar `
                     -AzureFileVolumeAccountCredential $credential `
                     -AzureFileVolumeShareName $shareName `
                     -AzureFileVolumeMountPath /share
