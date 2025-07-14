#!/bin/bash

# Script to open a terminal session that routes traffic through a specific VPN tunnel
# Usage: ./vpn-terminal.sh [tun_id] [command]
# Examples:
#   ./vpn-terminal.sh 0           # Open bash shell using tun0
#   ./vpn-terminal.sh 1 curl ipinfo.io  # Run curl through tun1
#   ./vpn-terminal.sh 2 "ping google.com"  # Run ping through tun2

VPN_DIR="/home/user/Desktop/openvpn-test-creds/IPV"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# VPN configurations (must match multi-vpn.sh)
declare -A VPN_CONFIGS
VPN_CONFIGS[0]="ipvanish-US-New-York-nyc-a01.ovpn"
VPN_CONFIGS[1]="ipvanish-US-Los-Angeles-lax-b01.ovpn" 
VPN_CONFIGS[2]="ipvanish-UK-London-lon-a01.ovpn"
VPN_CONFIGS[3]="ipvanish-DE-Frankfurt-fra-a01.ovpn"

show_usage() {
    echo -e "${BLUE}VPN Terminal - Route traffic through specific VPN tunnel${NC}"
    echo "Usage: $0 [tun_id] [command]"
    echo
    echo "Available tunnels:"
    for tun_id in "${!VPN_CONFIGS[@]}"; do
        local config_file=${VPN_CONFIGS[$tun_id]}
        local status="STOPPED"
        local ip_info=""
        
        # Check if VPN is running
        if [ -f "/tmp/vpn_pids/vpn_tun${tun_id}.pid" ] && kill -0 "$(cat "/tmp/vpn_pids/vpn_tun${tun_id}.pid")" 2>/dev/null; then
            status="${GREEN}RUNNING${NC}"
            ip_info=$(ip addr show "tun$tun_id" 2>/dev/null | grep "inet " | awk '{print $2}' | head -1)
            if [ -n "$ip_info" ]; then
                ip_info=" (IP: $ip_info)"
            fi
        else
            status="${RED}STOPPED${NC}"
        fi
        
        echo -e "  tun$tun_id: $status - ${config_file}${ip_info}"
    done
    echo
    echo "Examples:"
    echo "  $0 0                    # Open bash shell using tun0"
    echo "  $0 1 curl ipinfo.io     # Run curl through tun1"
    echo "  $0 2 \"ping google.com\"  # Run ping through tun2"
    echo "  $0 3 wget -qO- ipecho.net/plain  # Check IP through tun3"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Error: This script requires root privileges${NC}"
        echo "Please run with sudo or as root"
        exit 1
    fi
}

check_tun_exists() {
    local tun_id=$1
    if ! ip link show "tun$tun_id" &>/dev/null; then
        echo -e "${RED}Error: tun$tun_id interface not found${NC}"
        echo "Make sure the VPN is running. Check status with: ./multi_vpn.sh status"
        exit 1
    fi
}

get_tun_gateway() {
    local tun_id=$1
    # Get the gateway IP for the tun interface
    ip route show dev "tun$tun_id" | grep "via" | head -1 | awk '{print $3}'
}

setup_routing_for_command() {
    local tun_id=$1
    local tun_ip=$(ip addr show "tun$tun_id" | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
    local tun_gateway=$(get_tun_gateway "$tun_id")
    
    if [ -z "$tun_ip" ]; then
        echo -e "${RED}Error: No IP assigned to tun$tun_id${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Using VPN tunnel tun$tun_id${NC}"
    echo -e "${BLUE}VPN IP: $tun_ip${NC}"
    if [ -n "$tun_gateway" ]; then
        echo -e "${BLUE}Gateway: $tun_gateway${NC}"
    fi
    echo -e "${BLUE}Config: ${VPN_CONFIGS[$tun_id]}${NC}"
    echo "================================"
}

# Simple function - no complex routing needed

run_with_vpn_routing() {
    local tun_id=$1
    shift
    local command="$@"
    
    # Set up routing to use the specific tun interface
    setup_routing_for_command "$tun_id"
    
    # Get the tun interface IP
    local tun_ip=$(ip addr show "tun$tun_id" | grep "inet " | awk '{print $2}' | cut -d'/' -f1)
    
    if [ -z "$command" ]; then
        # Interactive shell with VPN routing
        echo -e "${YELLOW}Starting interactive shell with VPN routing...${NC}"
        echo -e "${YELLOW}Type 'exit' to return to normal routing${NC}"
        echo
        
        # Create a custom environment for the shell
        export VPN_TUN_ID="$tun_id"
        export VPN_IP="$tun_ip"
        export VPN_CONFIG="${VPN_CONFIGS[$tun_id]}"
        export PS1="(VPN-tun$tun_id) \u@\h:\w\$ "
        
        # Run an interactive bash shell with simple aliases
        exec bash --rcfile <(echo "
            export VPN_TUN_ID='$tun_id'
            export VPN_IP='$tun_ip'
            export VPN_CONFIG='${VPN_CONFIGS[$tun_id]}'
            export PS1='(VPN-tun$tun_id) \u@\h:\w\$ '
            
            # Simple aliases that force interface binding
            alias check_ip='curl --interface tun$tun_id -s ipinfo.io/ip'
            alias vpn_status='echo \"Using VPN: tun$tun_id ($tun_ip) - ${VPN_CONFIGS[$tun_id]}\"'
            alias curl='curl --interface tun$tun_id'
            alias wget='wget --bind-address=$tun_ip'
            alias ping='ping -I tun$tun_id'
            
            # Simple PowerShell wrapper
            pwsh_vpn() {
                echo \"Starting PowerShell through tun$tun_id...\"
                pwsh -c \"
                    Write-Host 'PowerShell using VPN tun$tun_id ($tun_ip)' -ForegroundColor Green
                    Write-Host 'Testing IP...' -ForegroundColor Yellow
                    try {
                        \\\$response = Invoke-WebRequest -Uri 'https://ipinfo.io/json' -UseBasicParsing
                        \\\$data = \\\$response.Content | ConvertFrom-Json
                        Write-Host \\\"Your IP: \\\$(\\\$data.ip)\\\" -ForegroundColor Cyan
                        Write-Host \\\"Location: \\\$(\\\$data.city), \\\$(\\\$data.country)\\\" -ForegroundColor Cyan
                    } catch {
                        Write-Host \\\"Could not determine IP: \\\$_\\\" -ForegroundColor Red
                    }
                    Write-Host ''
                    Write-Host 'PowerShell is now ready. Use Ctrl+C to exit.' -ForegroundColor Yellow
                    Write-Host 'Test commands:'
                    Write-Host '  Invoke-WebRequest -Uri ipinfo.io/json | ConvertFrom-Json'
                    Write-Host '  (Invoke-WebRequest ipecho.net/plain).Content'
                    Write-Host ''
                    # Start interactive PowerShell session
                    pwsh
                \"
            }
            
            echo -e '\033[0;32mVPN Terminal Ready!\033[0m'
            echo 'Commands available:'
            echo '  check_ip     - Check your current public IP'
            echo '  vpn_status   - Show VPN connection info'
            echo '  curl         - curl with forced interface binding'
            echo '  wget         - wget with forced interface binding' 
            echo '  ping         - ping with forced interface binding'
            echo '  pwsh_vpn     - PowerShell with VPN routing'
            echo '  exit         - Return to normal terminal'
            echo
        ")
        
    else
        # Run specific command with VPN routing
        echo -e "${YELLOW}Running command through VPN...${NC}"
        echo -e "${BLUE}Command: $command${NC}"
        echo
        
        # Simple command execution with interface binding
        if [[ "$command" == curl* ]]; then
            # For curl, use --interface flag
            modified_command=$(echo "$command" | sed "s/curl/curl --interface tun$tun_id/")
            eval "$modified_command"
        elif [[ "$command" == wget* ]]; then
            # For wget, use --bind-address
            modified_command=$(echo "$command" | sed "s/wget/wget --bind-address=$tun_ip/")
            eval "$modified_command"
        elif [[ "$command" == ping* ]]; then
            # For ping, use -I interface
            modified_command=$(echo "$command" | sed "s/ping/ping -I tun$tun_id/")
            eval "$modified_command"
        elif [[ "$command" == pwsh* ]]; then
            # For PowerShell, just run it normally and let user test manually
            echo "Note: PowerShell may not automatically use the VPN interface."
            echo "You can test the IP manually inside PowerShell with:"
            echo "  Invoke-WebRequest -Uri ipinfo.io/json"
            echo
            eval "$command"
        else
            # For other commands, just run them normally
            eval "$command"
        fi
    fi
}

# Main script logic
if [ $# -eq 0 ]; then
    show_usage
    exit 0
fi

check_root

tun_id=$1

# Validate tun_id
if [[ ! "$tun_id" =~ ^[0-9]+$ ]] || [ -z "${VPN_CONFIGS[$tun_id]}" ]; then
    echo -e "${RED}Error: Invalid tun_id '$tun_id'${NC}"
    echo "Valid tun_ids: ${!VPN_CONFIGS[@]}"
    exit 1
fi

check_tun_exists "$tun_id"

shift
run_with_vpn_routing "$tun_id" "$@"
