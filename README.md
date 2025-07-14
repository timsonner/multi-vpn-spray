# Multi VPN password spray
Objective: Connect to several VPN tunnels, then attach shells to tunnels to demonstrate password spray from multiple IPs  
This testing is done with IPVanish, YMMV with other .ovpn configs

## Preject setup  
- Download the configs
https://configs.ipvanish.com/configs/configs.zip

- Extract configs, place fix-configs.sh in configs directory and run it
- Place multi-vpn.sh in configs directory

## Start up multiple VPNs
```bash
cd configs && ./multi-vpn.sh
```

## Run VPN terminal  
```bash
vpn-terminal.sh
```




