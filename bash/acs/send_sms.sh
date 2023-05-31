#!/bin/bash

# Before using this script you need to:
# 
# 1. Create an ACS resource in the Azure Portal
# 2. Enable Alphanumeric Sender ID in the ACS resource
# 3. Copy the connection string from the "Keys" blade in the ACS resource

senderID="Contoso"                  # Up to 11 characters
recipient="+46000000000"            # Phone number in E.164 format
message="Hello World SMS Test"      # SMS message content
connString="endpoint=https://acsdemo1.communication.azure.com/;accesskey=dfTEsuCLrMPTJvameKhLRMAsmJ2VaejCuKI3f8VLlqBxZYfmYASTcbNt6ydaEh58bcq9xqQM3Ppi86dZZ5DRWg=="

az communication sms send --sender "$senderID" --recipient $recipient --message "$message" --connection-string $connString
