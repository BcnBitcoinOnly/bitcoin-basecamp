#!/bin/bash

# Use set -eu at the beginning of the script to exit immediately if any command in the script returns a non-zero exit code, or if any uninitialized variables are used. This can help prevent errors from being overlooked.
set -eu

# Load credentials from config file
CONFIG_FILE="/root/.secrets/cloudflare/config.json"
AUTH_EMAIL=$(jq -r '.user' "$CONFIG_FILE")
AUTH_KEY=$(jq -r '.key' "$CONFIG_FILE")

# Retrieve the last recorded public IP address
touch /tmp/ip-record
IP_RECORD="/tmp/ip-record"
RECORDED_IP=$(cat "$IP_RECORD")

# Log date
NOW=$(date -u +"%Y-%m-%d %H:%M:%S %Z")

# Fetch the current public IP address
PUBLIC_IP=$(dig +short myip.opendns.com @resolver1.opendns.com) || exit 1
# Alternative
#PUBLIC_IP=$(curl --silent https://api.ipify.org) || exit 1

#If the public ip has not changed, nothing needs to be done, exit.
if [ "$PUBLIC_IP" = "$RECORDED_IP" ]; then
        echo $NOW "  |   Actual Public IP is: $PUBLIC_IP   |   Public IP is still OK."
        exit 0
fi

# Otherwise, your Internet provider changed your public IP again.
# Record the new public IP address locally
echo $PUBLIC_IP > $IP_RECORD

# Loop through domains and update their DNS records on Cloudflare
for domain in $(jq -r '.domain' "$CONFIG_FILE"); do
    zone_id=$(jq -r '.zone' "$CONFIG_FILE")
    record_id=$(jq -r '.record_id' "$CONFIG_FILE")
    a_record_name=$(jq -r '.domain' "$CONFIG_FILE")

  echo "Changing DNS for $domain"
  RECORD=$(cat <<EOF
  { "type": "A",
  "name": "$a_record_name",
  "content": "$PUBLIC_IP",
  "ttl": 180,
  "proxied": true }
EOF
)

  # Update the record to Cloudflare
  curl "https://api.cloudflare.com/client/v4/zones/$zone_id/dns_records/$record_id" \
       -X PUT \
       -H "Content-Type: application/json" \
       -H "X-Auth-Email: $AUTH_EMAIL" \
       -H "X-Auth-Key: $AUTH_KEY" \
       -d "$RECORD"
  echo ""
done
