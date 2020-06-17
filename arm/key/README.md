# Upload your public SSH key to Azure
Finally you can now upload your own public SSH key to Azure for use when creating VMs via the Azure Portal.

Use this template. The key must be in OpenSSH format.

[![Deploy to Azure](https://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdohughes-msft%2Fsap%2Fmaster%2Farm%2Fkey%2Fupload_sshkey.json)

Here is an example of how you can reference an existing key when deploying using an ARM template:

In the variables (or parameters) section:
~~~~
    "variables": {
        "sshKeyRg": "sap-shared-rg1",
        "sshKeyName": "dohughes",
        "sshKeyResourceId": "[resourceId(variables('sshKeyRg'), 'Microsoft.Compute/sshPublicKeys', variables('sshKeyName'))]",
        "adminUser": "dohughes"
    },
~~~~

In the resources section for the VM:
~~~~
    "osProfile": {
        "computerName": "[variables('vmName')]",
        "adminUsername": "[variables('adminUser')]",
        "linuxConfiguration": {
            "disablePasswordAuthentication": true,
            "ssh": {
                "publicKeys": [
                    {
                        "keyData": "[reference(variables('sshKeyResourceId'), '2019-12-01').publicKey]",
                        "path": "[concat('/home/', variables('adminUser'), '/.ssh/authorized_keys')]"
                    }
                ]
            }
        }
    }
~~~~