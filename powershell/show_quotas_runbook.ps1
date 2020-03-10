# This PowerShell script will print the current quota usages for a given list of subscriptions.
# In array $inputs you should put the list of subscriptions and locations you want displayed, in JSON format. Description is free text and does not have to match the description in Azure.
# Only quotas with current value > 0 are shown. Use parameter -threshold to set the limit at which a warning will be shown in the status column.

param(
    [int]$threshold=70,
    [string]$credentialName="smtp",
    [string]$smtpServer="smtp.gmail.com",
    [string]$sender="don@donovanhughes.com",
    [string[]]$recipients=@("dohughes@microsoft.com", "don@donovanhughes.com"),
    [string]$subject="Monthly quota report from Microsoft Azure"
)

<# HM
$inputs = '[
    {
        "subscription": "95fce658-ff31-47e8-8c0c-8e29022f5024",
        "description": "EA_RCS_SAP_DEV_001",
        "locations": [
            "northeurope"
        ]
    },
    {
        "subscription": "3af3b1d7-1863-4cdb-b69c-38fd1179119c",
        "description": "EA_RCS_SAP_QAS_001",
        "locations": [
            "northeurope"
        ]
    },
    {
        "subscription": "73578047-33a3-4bd0-9eaa-3f465a38982e",
        "description": "EA_RCS_SAP_PROD_001",
        "locations": [
            "westeurope"
        ]
    },
    {
        "subscription": "959386c8-352b-42a9-8797-b0d4b24861a2",
        "description": "EA_RCS_SAP_PROD_TOOLS_001",
        "locations": [
            "westeurope",
            "northeurope"
        ]
    },
    {
        "subscription": "bb59e5fd-2bac-451a-92b0-0d3e70612a56",
        "description": "SAP FLOW EA",
        "locations": [
            "southeastasia"
        ]
    }
]'
#>

#Microsoft
$inputs = '{
    "subscription": "3e51b8f1-b856-4896-9a90-50ac02c27cf1",
    "description": "Dons Azure Playground",
    "locations": [
        "westus2"
    ]
}'

$inputsJson = $inputs | ConvertFrom-Json

$connection = Get-AutomationConnection -Name AzureRunAsConnection
Connect-AzAccount -ServicePrincipal -Tenant $connection.TenantID -ApplicationID $connection.ApplicationID -CertificateThumbprint $connection.CertificateThumbprint

foreach($sub in $inputsJson) {
    Set-AzContext -SubscriptionId $sub.subscription | Out-Null
    foreach($loc in $sub.locations) {
        $resultSet = Get-AzVMUsage -Location $loc | Where-Object CurrentValue -ne 0 | Select-Object CurrentValue, Limit -ExpandProperty Name | Select-Object @{n='Subscription';e={$sub.description}}, @{n='Location';e={$loc}}, @{n='Quota name';e={$_.LocalizedValue}}, CurrentValue, Limit, @{n='%used';e={[math]::Round(($_.CurrentValue/$_.Limit*100),2)}}, @{n='Status';e={
            if (($_.CurrentValue/$_.Limit*100) -gt $threshold) { "Warning" }
            else { "OK" }
        }}
    }
}

$style = "<style>BODY{font-family: Arial; font-size: 10pt;}"
$style = $style + "TABLE{border: 1px solid black; border-collapse: collapse;}"
$style = $style + "TH{border: 1px solid black; background: #dddddd; padding: 5px; }"
$style = $style + "TD{border: 1px solid black; padding: 5px; }"
$style = $style + "</style>"

$preamble = "Warnings are shown when quota usage exceeds $threshold%.<br><br>"

$mailBody = $resultSet | ConvertTo-Html -Head $style -PreContent $preamble | Out-String

$cred = Get-AutomationPSCredential -Name $credentialName

Send-MailMessage -To $recipients -Subject $subject -Body $mailBody -UseSsl -Port 587 -SmtpServer $smtpServer -From $sender -BodyAsHtml -Credential $cred
