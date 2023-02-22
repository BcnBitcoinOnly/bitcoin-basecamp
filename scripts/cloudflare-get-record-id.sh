/*
* This file is part of Bitcoin Basecamp
* Bitcoin Basecamp is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Bitcoin Basecamp is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Bitcoin Basecamp.  If not, see <https://www.gnu.org/licenses/>.
*/
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