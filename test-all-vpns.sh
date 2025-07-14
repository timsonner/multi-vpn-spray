#!/bin/bash

# Script to test credentials through each VPN tunnel
# Usage: ./test-all-vpns.sh [test-creds.ps1]

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Source shared VPN configuration
CONFIG_FILE="$SCRIPT_DIR/vpn-config.sh"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
else
    echo -e "${RED}Error: VPN configuration file not found at $CONFIG_FILE${NC}"
    exit 1
fi

# Check if PowerShell script is provided
POWERSHELL_SCRIPT="$1"
if [ -z "$POWERSHELL_SCRIPT" ]; then
    POWERSHELL_SCRIPT="test-creds.ps1"
fi

# Check if the PowerShell script exists
if [ ! -f "$SCRIPT_DIR/$POWERSHELL_SCRIPT" ]; then
    echo -e "${RED}Error: PowerShell script '$POWERSHELL_SCRIPT' not found in $SCRIPT_DIR${NC}"
    echo "Please create the script or specify a different path."
    exit 1
fi

# Check if we're running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Error: This script requires root privileges${NC}"
    echo "Please run with sudo or as root"
    exit 1
fi

# Check if vpn-terminal.sh exists
VPN_TERMINAL_SCRIPT="$SCRIPT_DIR/vpn-terminal.sh"
if [ ! -f "$VPN_TERMINAL_SCRIPT" ]; then
    echo -e "${RED}Error: vpn-terminal.sh not found at $VPN_TERMINAL_SCRIPT${NC}"
    exit 1
fi

echo -e "${BLUE}=== VPN Credential Testing Automation ===${NC}"
echo -e "${YELLOW}PowerShell Script: $POWERSHELL_SCRIPT${NC}"
echo -e "${YELLOW}Testing through ${#VPN_CONFIGS[@]} VPN tunnels...${NC}"
echo

# Function to get location from VPN config name
get_location() {
    local config="$1"
    # Extract location from filename like "ipvanish-US-New-York-nyc-a01.ovpn"
    echo "$config" | sed 's/ipvanish-\([^-]*\)-\([^-]*\).*/\1-\2/' | sed 's/-/ /'
}

# Iterate through all VPN configurations
for tun_id in $(printf '%s\n' "${!VPN_CONFIGS[@]}" | sort -n); do
    config_file="${VPN_CONFIGS[$tun_id]}"
    location=$(get_location "$config_file")
    
    echo -e "${CYAN}=== Testing through tun$tun_id ($location) ===${NC}"
    echo -e "${BLUE}Config: $config_file${NC}"
    
    # Check if this VPN tunnel is running
    if [ -f "/tmp/vpn_pids/vpn_tun${tun_id}.pid" ] && kill -0 "$(cat "/tmp/vpn_pids/vpn_tun${tun_id}.pid")" 2>/dev/null; then
        echo -e "${YELLOW}Running: $VPN_TERMINAL_SCRIPT $tun_id \"pwsh -File $SCRIPT_DIR/$POWERSHELL_SCRIPT\"${NC}"
        "$VPN_TERMINAL_SCRIPT" "$tun_id" "pwsh -File $SCRIPT_DIR/$POWERSHELL_SCRIPT"
        
        echo -e "${GREEN}Completed test for tun$tun_id ($location)${NC}"
        echo "----------------------------------------"
        echo
        
        # Pause between tests
        # echo -e "${YELLOW}Press Enter to continue to next VPN or Ctrl+C to stop...${NC}"
        # read
    else
        echo -e "${RED}Skipping tun$tun_id - VPN not running${NC}"
        echo -e "${YELLOW}Start it with: ./configs/multi-vpn.sh start $tun_id${NC}"
        echo
    fi
done

echo -e "${GREEN}=== All VPN credential tests completed! ===${NC}"
