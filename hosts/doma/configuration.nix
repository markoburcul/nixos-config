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
    ../../roles/zsh.nix
    ../../roles/users.nix
    ../../roles/docker.nix
    ../../roles/laptop-office.nix
  ];

  # System Boot Configuration
  boot = {
    loader.systemd-boot.enable = true;
    loader.grub.devices = [ "/dev/nvme0n1" ];    
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [ "mem_sleep_default=deep" ];
    kernelPackages = pkgs.linuxPackages_latest;
  };

  # Swap file for memory
  swapDevices = [ { device = "/var/lib/swapfile"; size = 4 * 1024; } ];

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
  };

  # Internationalization
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "hr_HR.UTF-8";
      LC_IDENTIFICATION = "hr_HR.UTF-8";
      LC_MEASUREMENT = "hr_HR.UTF-8";
      LC_MONETARY = "hr_HR.UTF-8";
      LC_NAME = "hr_HR.UTF-8";
      LC_NUMERIC = "hr_HR.UTF-8";
      LC_PAPER = "hr_HR.UTF-8";
      LC_TELEPHONE = "hr_HR.UTF-8";
      LC_TIME = "hr_HR.UTF-8";
    };
  };

  # Nix general settings
  nix = {
    settings = { 
      trusted-users = [ "root" "markob" ];
      extra-experimental-features = [ "flakes" "nix-command" ];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Barcelona";

  # Configure console keymap
  console.keyMap = "croat";

  system.stateVersion = "24.11";
}
