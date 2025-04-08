#!/bin/bash

# Configuration
HOSTS_FILE="/etc/hosts"
PF_ANCHOR="block_adult_sites"

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Restore original hosts file
if [ -f "${HOSTS_FILE}.backup" ]; then
    cp "${HOSTS_FILE}.backup" "$HOSTS_FILE"
else
    # If no backup, remove our entries
    sed -i '' '/^0\.0\.0\.0/d' "$HOSTS_FILE"
fi

# Flush DNS cache
dscacheutil -flushcache
killall -HUP mDNSResponder

# Remove PF rules
sudo pfctl -a "$PF_ANCHOR" -F all
sudo pfctl -t adult_sites -T flush
sudo pfctl -t adult_sites6 -T flush

# Disable PF
sudo pfctl -d

echo "All blocking has been removed successfully." 