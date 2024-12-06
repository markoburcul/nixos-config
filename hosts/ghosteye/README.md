# Description

Configuration for Hetzner Cloud CX22 VM.

Public IP: 49.13.212.18
DNS: ghosteye.cybercraftsolutions.eu

# Hardware

# TODO

# Installation

When creating in hetzner cloud web UI, add the cloud init script to install NixOS:
```
runcmd:
  - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | PROVIDER=hetznercloud NIX_CHANNEL=nixos-24.05 bash 2>&1 | tee /tmp/infect.log
```