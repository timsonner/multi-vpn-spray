# Multi VPN password spray
Objective: Connect to several VPN tunnels, then attach shells to tunnels to demonstrate password spray from multiple IPs  
This testing is done with IPVanish, YMMV with other .ovpn configs

## Preject setup  
- Download the configs
https://configs.ipvanish.com/configs/configs.zip

- Extract configs, place fix-configs.sh in configs directory and run it
- Place multi-vpn.sh in configs directory
- Create auth.txt with username and password each on oneline in configs directory
- Place vpn-config.sh in same directory as vpn-terminal.sh

## Project structure  
```
..
├── vpn-config.sh           # Shared VPN configurations
├── vpn-terminal.sh         # Terminal script (sources vpn-config.sh)
├── test-creds.ps1          # Authenticate as M365 user using ExchangeOnlineManagement
├── test-all-vpns.sh        # Runs test-creds.ps1 on all VPNs
└── configs/
    ├── fix-configs.sh      # Removes keysize and adds path to auth.txt
    ├── auth.txt            # Username and password for VPN
    └── multi-vpn.sh        # VPN management script (sources ../vpn-config.sh)
```

## Start up multiple VPNs
```bash
cd configs && ./multi-vpn.sh
```

## Run VPN terminal  
```bash
vpn-terminal.sh
```




