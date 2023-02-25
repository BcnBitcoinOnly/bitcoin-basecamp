#!/bin/bash
### 
# This script is used to check for changes in the public IP address of a domain and update the domain's DNS records on Cloudflare accordingly. 
# It uses API v4 to communicate with Cloudflare and requires authentication credentials to access the relevant DNS records. 
# If the public IP address has not changed, the script will exit. 
# If the public IP address has changed, the script will record the new IP address and update the DNS records on Cloudflare. 

# Use set -eu at the beginning of the script to exit immediately if any command in the script returns a non-zero exit code, or if any uninitialized variables are used. 
# This can help prevent errors from being overlooked.
set -eu

# Read Cloudflare authentication information from config file
CONFIG_FILE="/root/.secrets/cloudflare/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Config file not found at $CONFIG_FILE"
    exit 1
fi

CLOUDFLARE_EMAIL=$(jq -r '.cloudflare_email' "$CONFIG_FILE")
GLOBAL_API_KEY=$(jq -r '.global_api_key' "$CONFIG_FILE")

# Fetch the current public IP address
PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com) || exit 1
# Alternative
#PUBLIC_IP=$(curl --silent https://api.ipify.org) || exit 1

# Retrieve the last recorded public IP address for each domain
IP_RECORDS_DIR="/root/.secrets/cloudflare/ip_records"
mkdir -p "$IP_RECORDS_DIR"

DOMAINS=$(jq -c '.domains[]' "$CONFIG_FILE")
for DOMAIN in $DOMAINS; do
    A_RECORD_NAME=$(echo "$DOMAIN" | jq -r '.a_record_name')
    ZONE_ID=$(echo "$DOMAIN" | jq -r '.zone_id')
    RECORD_ID=$(echo "$DOMAIN" | jq -r '.record_id')

    IP_RECORD_FILE="$IP_RECORDS_DIR/$ZONE_ID-$RECORD_ID"
    touch "$IP_RECORD_FILE"
    RECORDED_IP=$(cat "$IP_RECORD_FILE")

    # Log date
    NOW=$(date -u +"%Y-%m-%d %H:%M:%S %Z")

    #If the public ip has not changed, nothing needs to be done, skip to the next domain.
    if [ "$PUBLIC_IP" = "$RECORDED_IP" ]; then
        echo "$NOW | Domain $A_RECORD_NAME ($ZONE_ID) | Actual Public IP is: $PUBLIC_IP | Public IP is still OK."
        continue
    fi

    # Otherwise, your Internet provider changed your public IP again.
    # Record the new public IP address locally
    echo "$PUBLIC_IP" > "$IP_RECORD_FILE"

    # Record the new public IP address on Cloudflare using API v4
    echo "$NOW | Domain $A_RECORD_NAME ($ZONE_ID) | Posting new Public IP to Cloudflare DNS.."
    echo ""

    RECORD=$(cat <<EOF
     { "type": "A",
     "name": "$A_RECORD_NAME",
     "content": "$PUBLIC_IP",
     "ttl": 180,
     "proxied": true }
     EOF
     )
    # Check API for authentication with tokens: https://developers.cloudflare.com/api
    curl "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
         -X PUT \
         -H "Content-Type: application/json" \
         -H "Authorization: Bearer $GLOBAL_API_KEY" \
         -d "$RECORD"
    echo ""
done