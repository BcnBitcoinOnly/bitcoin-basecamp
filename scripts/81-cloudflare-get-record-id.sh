#!/bin/sh

# Source: https://api.cloudflare.com/#dns-records-for-a-zone-dns-record-details

CONFIG_FILE="/root/.secrets/cloudflare/config.json"

# Create config file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  echo "{}" > "$CONFIG_FILE"
fi

# Prompt user for values
read -p "Enter your cloudflare email address: " USER
read -p "Enter your Global API Key: " GLOBAL_KEY
read -p "Enter your domain.tld: " A_RECORD_NAME
read -p "Enter your Zone ID: " ZONE_ID

# Check if JSON file exists
if [ -f auth_info.json ]; then
    # Read existing JSON data
    AUTH_INFO=$(cat auth_info.json)
else
    # Create empty JSON object
    AUTH_INFO="{}"
fi

# Get the current config file contents
config=$(cat "$CONFIG_FILE")

# Append the new values to the config file
new_config=$(echo "$config" | jq --arg user "$USER" --arg key "$GLOBAL_KEY" --arg domain "$A_RECORD_NAME" --arg zone "$ZONE_ID" '. + {"user": $user, "key": $key, "domain": $domain, "zone": $zone}')

# Write the updated config file contents back to the file
echo "$new_config" > "$CONFIG_FILE"