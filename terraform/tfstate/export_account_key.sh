#!/bin/bash

RESOURCE_GROUP_NAME=terraform-ne-rg1
STORAGE_ACCOUNT_NAME=tfstatene

ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' -o tsv)
export ARM_ACCESS_KEY=$ACCOUNT_KEY
