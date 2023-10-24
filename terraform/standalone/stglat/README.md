# Azure Site Recovery lab environment
With the Terraform and PowerShell configuration below you can create a simulated on-premises environment for testing of Azure Site Recovery.

## The on-premises environment
This environment consists of a virtual machine running four Hyper-V guests:

| Hostname | IP | Purpose |
| ----- | ----- | ----- |
| adserver | 192.168.1.10 | A Windows 2019 Server instance running an Active Directory Domain Controller for the contoso.com domain |
| fileserver | 192.168.1.11 | A Windows 2016 Server instance running file services |
| sqlserver | 192.168.1.12 | A Windows 2019 Server instance running SQL Server 2019 with the AdventureWorks database |
| ubuntu | 192.168.1.13 | An Ubuntu 20.04 Server instance |

The lab is based on deploying ASR agents on these machines, creating Recovery Services vault in Azure, and performing ASR failover.

## The Azure environment
Also included in the configuration are the Azure-native components needed to conduct the disaster recovery. These are:

* Storage account
* Recovery services vault
* Virtual network for test failover (with optional Bastion host)
* Virtual network for real failover (with optional Bastion host)

## Connectivity
This lab is designed to be run stand-alone without connectivity to a corporate network. Either public IP addresses or Azure Bastion may be used for access to on-prem and Azure VMs.

## Setting up the environment
1. Connect to the Azure Cloud Shell at https://shell.azure.com/ and switch to bash
2. Clone the lab repo:

```
git clone https://github.com/dohughes-msft/sap.git
cd sap/terraform/standalone/asrdemo/
mv terraform.tfvars.sample terraform.tfvars
code terraform.tfvars
```

3. Adjust the terraform variables to suit your requirements. Save and close the file.
4. Begin deployment:

```
terraform init
terraform apply
```

5. Once deployment is complete, log on to the virtual machine via Bastion or its public IP address.
6. Start Windows PowerShell and paste the following command:

```
Invoke-WebRequest https://raw.githubusercontent.com/dohughes-msft/sap/master/terraform/standalone/asrdemo/Configure-HyperVHost-Part1.ps1 | Invoke-Expression
```

7. The VM will perform some configuration and reboot.
8. After the restart, start PowerShell again and run the final configuration script:

```
Invoke-WebRequest https://raw.githubusercontent.com/dohughes-msft/sap/master/terraform/standalone/asrdemo/Configure-HyperVHost-Part2.ps1 | Invoke-Expression
```

This script imports the pre-installed Hyper-V guests from a storage account and will take some time.

9. Once the script is complete, the environment is ready and Hyper-V manager should show the running VMs.

## Credentials
Windows guest VMs: `Administrator / P4ssword!!!!`

Ubuntu guest VM: `administrator / P4ssword!!!!`

SQL administrator: `sa / P4ssword!!!!`
