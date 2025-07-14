# Multi VPN password spray/brute force
Objective: Connect to several VPN tunnels, attach shells to tunnels. Demonstrate password spray or brute force from multiple IPs  
The configs used in testing are from IPVanish, YMMV with other .ovpn configs

## Preject setup  
- Download the configs
https://configs.ipvanish.com/configs/configs.zip
- Extract configs, place fix-configs.sh in configs directory and run it
- Install PowerShell
- Install PowerShell module EchangeOnlineManagement
- Edit vpn-config.sh with VPNs you want to use
- Edit test-creds with credentials of user

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

## Run VPN terminal standalone
```bash
vpn-terminal.sh
```




