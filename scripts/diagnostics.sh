#!/bin/bash
# Enables diagnostic settings for the Databricks workspace following deployment

set -e

logs="[{\"category\":\"dbfs\",\"enabled\":true},{\"category\":\"clusters\",\"enabled\":true},{\"category\":\"accounts\",\"enabled\":true},{\"category\":\"jobs\",\"enabled\":true},{\"category\":\"notebook\",\"enabled\":true},{\"category\":\"ssh\",\"enabled\":true},{\"category\":\"workspace\",\"enabled\":true},{\"category\":\"secrets\",\"enabled\":true},{\"category\":\"sqlPermissions\",\"enabled\":true},{\"category\":\"instancePools\",\"enabled\":true}]"

echo "Enabling diagnostics for the deployed workspace..."
az monitor diagnostic-settings create --name diag \
--resource-group $1 \
--workspace $2 \
--storage-account $3 \
--resource $4 \
--logs $logs
echo "Enabled diagnostics!"
