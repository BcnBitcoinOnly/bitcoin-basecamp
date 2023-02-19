#!/bin/bash

# Use set -eu at the beginning of the script to exit immediately if any command in the script returns a non-zero exit code, or if any uninitialized variables are used. This can help prevent errors from being overlooked.
set -eu

AUTH_EMAIL="example@domain.tld"
AUTH_KEY="cloudflare_auth_key"

# Domain 1
# Domain name
A_RECORD_NAME1="domain1.com"
# Zone Id unique for each domain
ZONE_ID1="zoneid1"
# Get this through a script: cloudflare-get-record-id.sh
# Source: https://api.cloudflare.com/#getting-started-requests
A_RECORD_ID1="recordid1"

# Domain 2
# Domain name
A_RECORD_NAME2="domain2.com"
# Zone Id unique for each domain
ZONE_ID2="zoneid2"
A_RECORD_ID2="recordid2"

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

echo "Changing DNS for domain2"
RECORD2=$(cat <<EOF
{ "type": "A",
  "name": "$A_RECORD_NAME2",
  "content": "$PUBLIC_IP",
  "ttl": 180,
  "proxied": true }
EOF
)

# Update the record to Cloudflare
curl "https://api.cloudflare.com/client/v4/zones/$ZONE_ID2/dns_records/$A_RECORD_ID2" \
     -X PUT \
     -H "Content-Type: application/json" \
     -H "X-Auth-Email: $AUTH_EMAIL" \
     -H "X-Auth-Key: $AUTH_KEY" \
     -d "$RECORD2"
echo ""