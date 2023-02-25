#!/bin/bash
## This script is used to check for changes in the public IP address of a domain and update the domain's DNS records on Cloudflare accordingly. It uses API v4 to communicate with Cloudflare and requires authentication credentials to access the relevant DNS records. If the public IP address has not changed, the script will exit. If the public IP address has changed, the script will record the new IP address and update the DNS records on Cloudflare. The script handles changes for two domains, and requires the domain name, zone ID, and record ID to be specified in the script for each domain.

# Use set -eu at the beginning of the script to exit immediately if any command in the script returns a non-zero exit code, or if any uninitialized variables are used. This can help prevent errors from being overlooked.
set -eu

AUTH_EMAIL="example@domain.tld"
AUTH_KEY="cloudflare_auth_key"

# Domain name
A_RECORD_NAME1="domain1.com"
# Zone Id unique for each domain
ZONE_ID1="zoneid1"
# Get this through a script: cloudflare-get-record-id.sh
# Source: https://api.cloudflare.com/#getting-started-requests
A_RECORD_ID1="recordid1"

# Retrieve the last recorded public IP address
touch /tmp/ip-record
IP_RECORD="/tmp/ip-record"
RECORDED_IP=`cat $IP_RECORD`

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

# Record the new public IP address on Cloudflare using API v4
echo $NOW "Posting new Public IP to Cloudflare DNS.."
echo ""

echo "Changing DNS for domain1"
RECORD1=$(cat <<EOF
{ "type": "A",
  "name": "$A_RECORD_NAME1",
  "content": "$PUBLIC_IP",
  "ttl": 180,
  "proxied": true }
EOF
)
# NOT WORKING YET - ONLY GLOBAL KEY - Check API for authentication with tokens: https://api.cloudflare.com/#getting-started-requests
curl "https://api.cloudflare.com/client/v4/zones/$ZONE_ID1/dns_records/$A_RECORD_ID1" \
     -X PUT \
     -H "Content-Type: application/json" \
     -H "X-Auth-Email: $AUTH_EMAIL" \
     -H "X-Auth-Key: $AUTH_KEY" \
     -d "$RECORD1"
echo ""