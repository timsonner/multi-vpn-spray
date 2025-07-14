#!/bin/bash

# Script to test usernames from users.txt through different VPN tunnels
# Usage: ./test-users-vpn-cycle.sh

# Source the VPN configuration
source ./vpn-config.sh

USERS_FILE="users.txt"
POWERSHELL_SCRIPT="test-single-user.ps1"

# Check if users file exists
if [[ ! -f "$USERS_FILE" ]]; then
    echo "Error: $USERS_FILE not found!"
    exit 1
fi

# Check if PowerShell script exists
if [[ ! -f "$POWERSHELL_SCRIPT" ]]; then
    echo "Error: $POWERSHELL_SCRIPT not found!"
    exit 1
fi

# Read usernames into array
mapfile -t USERNAMES < "$USERS_FILE"

# Remove empty lines
USERNAMES=($(printf '%s\n' "${USERNAMES[@]}" | grep -v '^$'))

if [[ ${#USERNAMES[@]} -eq 0 ]]; then
    echo "Error: No usernames found in $USERS_FILE"
    exit 1
fi

echo "Found ${#USERNAMES[@]} usernames to test"
echo "Found ${#VPN_CONFIGS[@]} VPN configurations"
echo "Starting username/VPN cycle testing..."
echo "=================================="

# Counter for VPN selection
vpn_index=0

# Test each username with a different VPN
for username in "${USERNAMES[@]}"; do
    # Skip empty usernames
    [[ -z "$username" ]] && continue
    
    # Get current VPN config (cycle through available VPNs)
    current_vpn=${VPN_CONFIGS[$vpn_index]}
    vpn_name=$(basename "$current_vpn" .ovpn)
    
    echo ""
    echo "Testing: $username through VPN: $vpn_name (tun$vpn_index)"
    echo "----------------------------------------"
    
    # Run the PowerShell script through VPN
    ./vpn-terminal.sh $vpn_index "pwsh -File $(pwd)/$POWERSHELL_SCRIPT -Username '$username'"
    
    # Move to next VPN (cycle back to 0 if we reach the end)
    vpn_index=$(( (vpn_index + 1) % ${#VPN_CONFIGS[@]} ))
    
    # Add a small delay between tests
    sleep 2
done

echo ""
echo "=================================="
echo "Username/VPN cycle testing completed!"
echo "Tested ${#USERNAMES[@]} usernames across ${#VPN_CONFIGS[@]} VPN endpoints"
