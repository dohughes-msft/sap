# SFTP container solution for Azure
With the Azure Resource Manager template here you can deploy public or private container instances and provide a PaaS-like SFTP service to clients, backed by Azure File storage.

These templates build upon the work done here:

https://github.com/Azure-Samples/sftp-creation-template

and add features such as:
* Any number of SFTP users and file shares can be used
* Password hashes

## Getting started

To get started you will need:

1. A VNET with a subnet delegated to container groups (Microsoft.ContainerInstance/containerGroups)
2. A storage account containing one Azure file share for each SFTP user

## Parameter inputs

To deploy the SFTP container you need to specify:

1. Resource group containing the VNET
2. VNET name
3. Subnet name
4. Resource group containing the storage account
5. Storage account name
6. List of users, password hashes and file shares

See file `sftp_private.parameter.json` for an example.

## Deployment result

The result will be a running container that provides an SFTP service with the users specified, backed by individual Azure file shares.

~~~~
# df -h
Filesystem                                Size  Used Avail Use% Mounted on
overlay                                    49G   12G   38G  24% /
tmpfs                                     7.9G     0  7.9G   0% /dev
tmpfs                                     7.9G     0  7.9G   0% /sys/fs/cgroup
tmpfs                                     7.9G  4.0K  7.9G   1% /var/aci_metadata
/dev/sda1                                  49G   12G   38G  24% /etc/hosts
shm                                        64M     0   64M   0% /dev/shm
//sftpaccount1.file.core.windows.net/s10  5.0T   64K  5.0T   1% /home/s10ftp/upload
//sftpaccount1.file.core.windows.net/d10  5.0T     0  5.0T   0% /home/d10ftp/upload
//sftpaccount1.file.core.windows.net/t10  5.0T     0  5.0T   0% /home/t10ftp/upload
tmpfs                                     7.9G     0  7.9G   0% /sys/firmware
~~~~
