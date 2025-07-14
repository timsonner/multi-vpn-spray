#!/bin/bash

# Script to test usernames from users.txt through different VPN tunnels
# Distributes users evenly across available VPNs
# Usage: ./test-users-distributed.sh [users_per_vpn]

# Source the VPN configuration
source ./vpn-config.sh

USERS_FILE="users.txt"
POWERSHELL_SCRIPT="test-single-user.ps1"
USERS_PER_VPN=${1:-2}  # Default to 2 users per VPN if not specified

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
echo "Testing $USERS_PER_VPN users per VPN"
echo "Starting distributed testing..."
echo "=================================="

# Test users in batches per VPN
user_index=0
for (( vpn_index=0; vpn_index<${#VPN_CONFIGS[@]}; vpn_index++ )); do
    # Get current VPN config
    current_vpn=${VPN_CONFIGS[$vpn_index]}
    vpn_name=$(basename "$current_vpn" .ovpn)
    
    echo ""
    echo "Testing through VPN: $vpn_name (tun$vpn_index)"
    echo "----------------------------------------"
    
    # Test specified number of users for this VPN
    for (( i=0; i<$USERS_PER_VPN && user_index<${#USERNAMES[@]}; i++ )); do
        username=${USERNAMES[$user_index]}
        
        # Skip empty usernames
        if [[ -n "$username" ]]; then
            echo "Testing: $username"
            ./vpn-terminal.sh $vpn_index "pwsh -File $(pwd)/$POWERSHELL_SCRIPT -Username '$username'"
            sleep 1
        fi
        
        ((user_index++))
    done
    
    # Break if we've tested all users
    if [[ $user_index -ge ${#USERNAMES[@]} ]]; then
        break
    fi
    
    # Add delay between VPN switches
    sleep 2
done

echo ""
echo "=================================="
echo "Distributed testing completed!"
echo "Tested $user_index usernames across VPN endpoints"

# Show any remaining untested users
if [[ $user_index -lt ${#USERNAMES[@]} ]]; then
    remaining=$((${#USERNAMES[@]} - user_index))
    echo "Note: $remaining users remaining (not enough VPN slots)"
    echo "Remaining users:"
    for (( i=user_index; i<${#USERNAMES[@]}; i++ )); do
        echo "  - ${USERNAMES[$i]}"
    done
fi
