#!/bin/bash

# Configuration
ADULT_SITES_FILE="list.txt"
TEMP_IP_FILE="temp_ips.txt"
TEMP_IPV6_FILE="temp_ips6.txt"
HOSTS_FILE="/etc/hosts"
PF_ANCHOR="block_adult_sites"

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Backup hosts file
cp "$HOSTS_FILE" "${HOSTS_FILE}.backup"

# Function to resolve domains
resolve_domain() {
    local domain=$1
    # Get all A records
    dig +short A "$domain" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
    # Get all AAAA records
    dig +short AAAA "$domain" | grep -E '^[0-9a-fA-F:]+$'
    # Try common subdomains
    for sub in www m www2 api app; do
        dig +short A "${sub}.${domain}" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$'
        dig +short AAAA "${sub}.${domain}" | grep -E '^[0-9a-fA-F:]+$'
    done
}

# Get the primary network interface
INTERFACE=$(route get default | grep interface | awk '{print $2}')

# Create temporary files
> "$TEMP_IP_FILE"
> "$TEMP_IPV6_FILE"

# Process each domain
while read -r domain; do
    [ -z "$domain" ] && continue
    
    # Add to hosts file
    echo "0.0.0.0 $domain" >> "$HOSTS_FILE"
    echo "0.0.0.0 www.$domain" >> "$HOSTS_FILE"
    
    # Resolve and add IPs
    resolve_domain "$domain" | while read -r ip; do
        if [[ $ip =~ : ]]; then
            echo "$ip" >> "$TEMP_IPV6_FILE"
        else
            echo "$ip" >> "$TEMP_IP_FILE"
        fi
    done
done < "$ADULT_SITES_FILE"

# Flush DNS cache
dscacheutil -flushcache
killall -HUP mDNSResponder

# Create PF tables
sudo pfctl -t adult_sites -T replace -f "$TEMP_IP_FILE"
sudo pfctl -t adult_sites6 -T replace -f "$TEMP_IPV6_FILE"

# Load PF rules
sudo pfctl -a "$PF_ANCHOR" -f - <<EOF
table <adult_sites> persist
table <adult_sites6> persist

# Block all traffic to/from blocked IPs
block in quick on $INTERFACE from any to <adult_sites>
block out quick on $INTERFACE from any to <adult_sites>
block in quick on $INTERFACE from <adult_sites> to any
block out quick on $INTERFACE from <adult_sites> to any

# Block IPv6 traffic
block in quick on $INTERFACE from any to <adult_sites6>
block out quick on $INTERFACE from any to <adult_sites6>
block in quick on $INTERFACE from <adult_sites6> to any
block out quick on $INTERFACE from <adult_sites6> to any

# Allow other traffic
pass in quick on $INTERFACE
pass out quick on $INTERFACE
EOF

# Enable PF
sudo pfctl -e
sudo pfctl -f /etc/pf.conf

# Clean up
rm -f "$TEMP_IP_FILE" "$TEMP_IPV6_FILE"

echo "Blocking has been applied successfully."
echo "Blocked IPv4 addresses:"
sudo pfctl -t adult_sites -T show
echo -e "\nBlocked IPv6 addresses:"
sudo pfctl -t adult_sites6 -T show