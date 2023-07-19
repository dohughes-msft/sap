# Azure Site Recovery lab environment
With the Terraform and PowerShell configuration below you can create a simulated on-premises environment for testing of Azure Site Recovery.

## The on-premises environment
This environment consists of an Azure virtual machine running four Hyper-V guests:

| Hostname | IP | Purpose |
| ----- | ----- | ----- |
| adserver | 192.168.1.10 | A Windows 2019 Server instance running an Active Directory Domain Controller for the contoso.com domain |
| fileserver | 192.168.1.11 | A Windows 2016 Server instance running file services |
| sqlserver | 192.168.1.12 | A Windows 2019 Server instance running SQL Server 2019 with the AdventureWorks database |
| ubuntu | 192.168.1.13 | An Ubuntu 20.04 Server instance |

The lab is based on deploying ASR agents on these machines, creating Recovery Services vault in Azure, and performing ASR failover.

## Setting up the environment
1. Run "terraform apply" to set up the Azure infrastructure
2. Log on to the virtual machine via Bastion or its public IP address, if chosen
3. Start Windows PowerShell ISE on the VM and click New Script
4. Copy the contents of script Configure-HyperVHost-Part1.ps1 from the repo to the PowerShell ISE window and run it
5. The VM will perform some configuration and reboot
6. After the restart, start PowerShell ISE again and repeat the procedure with script Configure-HyperVHost-Part2.ps1. This script imports the pre-installed Hyper-V guests from a storage account and will take some time.
7. Once the script is complete, the environment is ready and you can start the Hyper-V VMs

## Credentials
Windows guest VMs: Administrator / P4ssword!!!!

Ubuntu guest VM: administrator / P4ssword!!!!

SQL administrator: sa / P4ssword!!!!
