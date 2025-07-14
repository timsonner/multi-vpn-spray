#!/bin/bash

# Shared VPN configuration for multi-vpn.sh and vpn-terminal.sh
# This file should be sourced by other scripts

# Define VPN configurations
declare -A VPN_CONFIGS
VPN_CONFIGS[0]="ipvanish-US-New-York-nyc-a01.ovpn"
VPN_CONFIGS[1]="ipvanish-US-Los-Angeles-lax-b01.ovpn" 
VPN_CONFIGS[2]="ipvanish-UK-London-lon-a01.ovpn"
VPN_CONFIGS[3]="ipvanish-DE-Frankfurt-fra-a01.ovpn"

# You can add more VPN configurations here as needed
# VPN_CONFIGS[4]="ipvanish-CA-Toronto-yyz-a01.ovpn"
# VPN_CONFIGS[5]="ipvanish-JP-Tokyo-nrt-a01.ovpn"

# Export the array so it's available to sourcing scripts
export VPN_CONFIGS
