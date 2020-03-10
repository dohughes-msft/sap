<#
.SYNOPSIS
    Display current quota usages and limits for a given list of subscriptions and mail the result to a list of recipients.
    This script should be run as an Azure Automation runbook.
.EXAMPLE
    PS C:\> email_quotas.ps1
.INPUTS
    -threshold <nn>              : the limit in % above which a warning will be shown in the status column
    -credentialName <credential> : the name of the credential stored in Azure Automation for the SMTP server
    -smtpServer <server>         : the FQDN of the SMTP server
    -sender <email>              : email address of the sender
    -recipients <email, email>   : comma-separated list of recipients
    -subject <subject>           : subject of the mail
    $inputs                      : an inline variable in JSON format containing a list of subscriptions and locations that are in scope

    Example:
        $inputs = '[
            {
                "subscription": "5e3380ac-b138-468e-b4a7-aa9e24353999",
                "description": "Free text, this will show up in the output instead of the subscription ID",
                "locations": [
                    "westus2"
                ]
            },
            {
                "subscription": "9681cbdd-0eba-4428-a829-7a98fbd45d06",
                "description": "Free text, does not have to match the name in Azure",
                "locations": [
                    "westus2",
                    "eastus"
                ]
            }
        ]'

.OUTPUTS
    A table of subscriptions, locations and quotas will be emailed to the recipients.
.NOTES
    Only quotas in use (>0) are shown.
#>

param(
    [int]$threshold=70,
    [string]$credentialName="smtp",
    [string]$smtpServer="smtp.gmail.com",
    [string]$sender="contact@donovanhughes.com",
    [string]$recipients="dohughes@microsoft.com, don@donovanhughes.com",
    [string]$subject="Monthly quota report from Microsoft Azure"
)

#Microsoft
$inputs = '{
    "subscription": "3e51b8f1-b856-4896-9a90-50ac02c27cf1",
    "description": "Dons Azure Playground",
    "locations": [
        "westus2"
    ]
}'

$inputsJson = $inputs | ConvertFrom-Json
$cred = Get-AutomationPSCredential -Name $credentialName
$connection = Get-AutomationConnection -Name AzureRunAsConnection

Connect-AzAccount -ServicePrincipal -Tenant $connection.TenantID -ApplicationID $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

foreach($sub in $inputsJson) {
    Set-AzContext -SubscriptionId $sub.subscription | Out-Null
    foreach($loc in $sub.locations) {
        $resultSet = Get-AzVMUsage -Location $loc `
            | Where-Object `
                CurrentValue -ne 0 `
            | Select-Object `
                CurrentValue, `
                Limit `
                -ExpandProperty Name `
            | Select-Object `
                @{n='Subscription';e={$sub.description}}, `
                @{n='Location';e={$loc}}, `
                @{n='Quota name';e={$_.LocalizedValue}}, `
                CurrentValue, `
                Limit, `
                @{n='%used';e={[math]::Round(($_.CurrentValue/$_.Limit*100),2)}}, `
                @{n='Status';e={
                    if (($_.CurrentValue/$_.Limit*100) -gt $threshold) {
                        "Warning"
                    } else {
                        "OK"
                    }
                }}
    }
}

# Add some styles to make the table readable when received as HTML
$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

$preamble = "Warnings are shown when quota usage exceeds $threshold%.<br><br>"
$mailBody = $resultSet | ConvertTo-Html -Head $style -PreContent $preamble | Out-String
$toList = $recipients -split ","

Send-MailMessage -To $toList -Subject $subject -Body $mailBody -UseSsl -Port 587 -SmtpServer $smtpServer -From $sender -BodyAsHtml -Credential $cred