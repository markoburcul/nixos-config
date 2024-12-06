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
    ../../roles/go-ethereum-holesky.nix
    ../../roles/nimbus-eth2-holesky.nix
    ../../roles/netdata.nix
    ../../roles/prometheus.nix
    (
      import ../../roles/promtail.nix (
        args // { 
          lokiHost = "49.13.212.18";
          lokiPort = 3030;
        }
      )
    )
  ];

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking = {
    hostName = "torvion";
    domain   = "cybercraftsolutions.eu";
    # The primary use case is to ensure when using ZFS that a pool isn’t imported accidentally on a wrong machine
    hostId   = "cc4068bf";
    useDHCP  = true;
  };

  networking.firewall.extraInputRules = ''
    ip saddr 49.13.212.18 tcp dport 9000 accept comment "Ghosteye Prometheus scrape Netdata"
    ip saddr 49.13.212.18 tcp dport 9100 accept comment "Ghosteye Prometheus scrape Nimbus Beacon Node"
    ip saddr 49.13.212.18 tcp dport 16060 accept comment "Ghosteye Prometheus scrape Geth Node"
  '';

  # Set your time zone.
  time.timeZone = "Europe/Barcelona";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Configure console keymap
  console.keyMap = "croat";

  services.openssh.enable = true;

  system.stateVersion = "24.05";
}
