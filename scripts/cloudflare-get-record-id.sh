#!/bin/sh

# Source: https://api.cloudflare.com/#dns-records-for-a-zone-dns-record-details

#Set values below
USER="domain.tld"
GLOBAL_KEY="global_key"
ZONE_ID="zone_id"

curl -X GET "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records" \
     -H "Content-Type:application/json" \
     -H "X-Auth-Key:$GLOBAL_KEY" \
     -H "X-Auth-Email:$USER" \
     -H "Content-Type: application/json"