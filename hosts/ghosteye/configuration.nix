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
    ../../roles/promtail.nix
    ../../roles/loki.nix
    ../../roles/nebula.nix
    ../../roles/landing.nix
  ];

  services.promtail = {
    enable = true;                  
    lokiHost = "localhost";
    lokiPort = 3030;
  };

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

  # Set your time zone.
  time.timeZone = "Europe/Barcelona";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure console keymap
  console.keyMap = "croat";

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
