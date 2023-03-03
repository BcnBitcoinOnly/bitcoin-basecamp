#!/bin/sh
# Source: https://api.cloudflare.com/#dns-records-for-a-zone-dns-record-details

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Path to the Cloudflare config file
CONFIG_FILE="/root/.secrets/cloudflare/config.json"

# Create config file if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
  echo "{}" > "$CONFIG_FILE"
fi

# Prompt user for domain name
echo "Please provide the domain name for the A record:"
read -p "Domain name (e.g. example.com): " A_RECORD_NAME

# Check if the domain name exists in the config file
if grep -q "\"domain\": \"$A_RECORD_NAME\"" "$CONFIG_FILE"; then
    # Domain name exists in the config file, so retrieve the record ID
    RECORD_ID=$(jq -r ". | select(.domain == \"$A_RECORD_NAME\") | .record_id" "$CONFIG_FILE")
    echo "The record ID for $A_RECORD_NAME is $RECORD_ID."
    exit
fi

# Prompt user for Cloudflare authentication information
echo "Please provide your Cloudflare authentication information:"
read -p "Email address: " USER
read -p "Global API Key: " GLOBAL_KEY
read -p "Zone ID: " ZONE_ID

# Retrieve record ID for the A record
RECORD_ID=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$A_RECORD_NAME" \
     -H "Content-Type:application/json" \
     -H "X-Auth-Key:$GLOBAL_KEY" \
     -H "X-Auth-Email:$USER" | jq -r '.result[0].id')

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
new_config=$(echo "$config" | jq --arg user "$USER" --arg key "$GLOBAL_KEY" --arg domain "$A_RECORD_NAME" --arg zone "$ZONE_ID" --arg id "$RECORD_ID" '. + {"user": $user, "key": $key, "domain": $domain, "zone": $zone, "record_id": $id}')

# Write the updated config file contents back to the file
echo "$new_config" > "$CONFIG_FILE"

echo "Cloudflare authentication information and record ID for $A_RECORD_NAME have been saved to $CONFIG_FILE."
