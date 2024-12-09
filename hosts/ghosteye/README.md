# Description

Configuration for Hetzner Cloud CX22 VM.

Public IP: 49.13.212.18
Nebula Private IP: 192.170.100.1
Nebula Groups: monitoring, ssh
DNS: ghosteye.cybercraftsolutions.eu

# Hardware

- 2vCPU
- 4GB RAM
- 50 GB SSD

# Installation

When creating in hetzner cloud web UI, add the cloud init script to install NixOS:
```
runcmd:
  - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=hetznercloud NIX_CHANNEL=nixos-24.05 bash 2>&1 | tee /tmp/infect.log
```