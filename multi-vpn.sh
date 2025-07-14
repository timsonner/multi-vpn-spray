#!/bin/bash

# Script to manage multiple OpenVPN connections with different tun interfaces
# Usage: ./multi-vpn.sh start|stop|status

VPN_DIR="/home/user/Desktop/openvpn-test-creds/configs/"
LOG_DIR="/tmp/vpn_logs"
PID_DIR="/tmp/vpn_pids"

# Create temp directories if they don't exist
mkdir -p "$LOG_DIR" "$PID_DIR"

# Define VPN configurations
declare -A VPN_CONFIGS
VPN_CONFIGS[0]="ipvanish-US-New-York-nyc-a01.ovpn"
VPN_CONFIGS[1]="ipvanish-US-Los-Angeles-lax-b01.ovpn" 
VPN_CONFIGS[2]="ipvanish-UK-London-lon-a01.ovpn"
VPN_CONFIGS[3]="ipvanish-DE-Frankfurt-fra-a01.ovpn"

start_vpn() {
    local tun_id=$1
    local config_file=${VPN_CONFIGS[$tun_id]}
    
    if [ -z "$config_file" ]; then
        echo "No config defined for tun$tun_id"
        return 1
    fi
    
    echo "Starting VPN on tun$tun_id with config: $config_file"
    
    # Create modified config file with specific tun device
    local temp_config="/tmp/vpn_tun${tun_id}.ovpn"
    cp "$VPN_DIR/$config_file" "$temp_config"
    
    # Modify the config to use specific tun device
    sed -i "s/^dev tun$/dev tun$tun_id/" "$temp_config"
    
    # Start OpenVPN with specific parameters
    openvpn \
        --config "$temp_config" \
        --dev "tun$tun_id" \
        --daemon \
        --log "$LOG_DIR/vpn_tun${tun_id}.log" \
        --writepid "$PID_DIR/vpn_tun${tun_id}.pid" \
        --script-security 2
        
    echo "VPN started on tun$tun_id (PID: $(cat $PID_DIR/vpn_tun${tun_id}.pid 2>/dev/null))"
}

stop_vpn() {
    local tun_id=$1
    local pid_file="$PID_DIR/vpn_tun${tun_id}.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        echo "Stopping VPN on tun$tun_id (PID: $pid)"
        kill "$pid" 2>/dev/null
        rm -f "$pid_file"
        rm -f "/tmp/vpn_tun${tun_id}.ovpn"
    else
        echo "No VPN running on tun$tun_id"
    fi
}

status_vpn() {
    echo "VPN Status:"
    echo "==========="
    
    for tun_id in "${!VPN_CONFIGS[@]}"; do
        local pid_file="$PID_DIR/vpn_tun${tun_id}.pid"
        if [ -f "$pid_file" ] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
            local config_file=${VPN_CONFIGS[$tun_id]}
            echo "tun$tun_id: RUNNING (${config_file})"
            ip addr show "tun$tun_id" 2>/dev/null | grep "inet " || echo "  No IP assigned yet"
        else
            echo "tun$tun_id: STOPPED"
        fi
        echo
    done
}

case "$1" in
    start)
        if [ -n "$2" ]; then
            start_vpn "$2"
        else
            echo "Starting all VPN connections..."
            for tun_id in "${!VPN_CONFIGS[@]}"; do
                start_vpn "$tun_id"
                sleep 2  # Delay between connections
            done
        fi
        ;;
    stop)
        if [ -n "$2" ]; then
            stop_vpn "$2"
        else
            echo "Stopping all VPN connections..."
            for tun_id in "${!VPN_CONFIGS[@]}"; do
                stop_vpn "$tun_id"
            done
        fi
        ;;
    status)
        status_vpn
        ;;
    *)
        echo "Usage: $0 {start|stop|status} [tun_id]"
        echo "Examples:"
        echo "  $0 start        # Start all VPNs"
        echo "  $0 start 0      # Start only tun0"
        echo "  $0 stop 1       # Stop only tun1"
        echo "  $0 status       # Show status of all"
        exit 1
        ;;
esac
