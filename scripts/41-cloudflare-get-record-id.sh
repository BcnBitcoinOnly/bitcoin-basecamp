#!/bin/sh

# Source: https://api.cloudflare.com/#dns-records-for-a-zone-dns-record-details

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Prompt user for values
read -p "Enter your cloudflare email address: " USER
read -p "Enter your Global API Key: " GLOBAL_KEY
read -p "Enter your Zone ID: " ZONE_ID

curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
     -H "Content-Type:application/json" \
     -H "X-Auth-Key:$GLOBAL_KEY" \
     -H "X-Auth-Email:$USER" \
     -H "Content-Type: application/json"

# Extract record ID from response
RECORD_ID=$(echo $response | jq -r '.result[0].id')

# Save record ID to secrets folder
sudo mkdir -p /root/.secrets/cloudflare
sudo echo $RECORD_ID > /root/.secrets/cloudflare/record_id_$ZONE_ID