args@{
  modulesPath,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ../../roles/base.nix
    ../../roles/security.nix
    ../../roles/network.nix
    ../../roles/zsh.nix
    ../../roles/users.nix
    ../../roles/netdata.nix
    ../../roles/prometheus.nix
    ../../roles/grafana.nix
    (
      import ../../roles/promtail.nix (
        args // { 
          lokiHost = "ghosteye.mesh";
          lokiPort = 3030;
        }
      )
    )
    (
      import ../../roles/loki.nix (
        args // { 
          lokiIngesters = [ "88.198.54.19" ]; 
        }
      )
    )
    (
      import ../../roles/nebula.nix (
        args // { 
          isLighthouse = true; 
        }
      )
    )
    ../../roles/landing.nix
  ];

  # Necessary for Hetzner Cloud
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
    device = "nodev";
  };

  networking = {
    hostName = "ghosteye";
    domain   = "cybercraftsolutions.eu";
    # The primary use case is to ensure when using ZFS that a pool isn’t imported accidentally on a wrong machine
    hostId   = "dc21a8bf";
    useDHCP  = true;
  };

  #networking.firewall.extraInputRules = ''
  #  ip saddr 88.198.54.19 tcp dport 3030 accept comment "Torvion Promtail sending logs to Loki"
  #'';

  # Set your time zone.
  time.timeZone = "Europe/Barcelona";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure console keymap
  console.keyMap = "croat";

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
