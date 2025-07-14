# Multi VPN password spray/brute force
Objective: Connect to several VPN tunnels, attach shells to tunnels. Demonstrate password spray or brute force from multiple IPs  
The configs used in testing are from IPVanish, YMMV with other .ovpn configs

## Preject setup  
- Download the configs
https://configs.ipvanish.com/configs/configs.zip
- Extract configs, place fix-configs.sh in configs directory and run it
- Edit auth.txt with VPN credentials, place auth.txt in configs directory
- Install PowerShell
- Install PowerShell module EchangeOnlineManagement
- Edit vpn-config.sh with VPNs configs you want to use
- CHMOD +x all the .sh files
- Start VPNs with multi-vpn.sh
- Modify password in test-single-user.ps1 and test-creds.ps1
- Modify users.txt

## Project structure  
```
..
├── vpn-config.sh               # VPN configuration used by multi-vpn.sh and vpn-terminal.sh
├── vpn-terminal.sh             # Standalone interactive terminal, also runs scripts as parameter
├── test-creds.ps1              # Authenticate as M365 user using ExchangeOnlineManagement
├── test-all-vpns.sh            # Runs .ps1 script provided as parameter on all VPNs
├── test-users-distributed.sh   # Test x number of users in wordlist per VPN
├── test-users-vpn-cycle.sh     # Cycle through users in worlist, 1 try per VPN
├── test-single-user.ps1        # Modified test-creds.ps1 that accepts a username as a parameter
├── users.txt                   # Used by test-users-vpn-cycle.sh and test-users-distributed.sh
└── configs/
    ├── fix-configs.sh          # Removes keysize and adds path to auth.txt
    ├── auth.txt                # Username and password for VPN
    └── multi-vpn.sh            # VPN management script (VPN daemon of sorts)
```

## Start up multiple VPNs (required)
```bash
cd configs && ./multi-vpn.sh
```

## Run VPN terminal in standalone mode
```bash
vpn-terminal.sh
```

## Test creds of single user (good for fail/success error messages and testing)
```bash
test-all-vpns.sh test-creds.ps1 
```

## Password spray cycling through VPNs 
```bash
test-users-vpn-cycle.sh
```

## Password spray x number of users per VPN
```bash
test-users-distributed.sh
```







