{ pkgs, ... }:

{
  # Packages
  environment.systemPackages = with pkgs; [
    # utilities
    file zsh bash man-pages sudo bc pv rename uptimed lsb-release
    # building
    gnumake gcc autoconf automake patchelf
    unzip zip envsubst entr
    # processes
    dtach pstree killall sysstat
    # monitoring
    htop iotop iftop multitail earlyoom
    # dev tools
    neovim jq tmux fzf silver-searcher
    git qrencode sqlite
    # devops
    docker docker-compose
    # hardware tools
    pciutils lm_sensors acpi pmutils usbutils dmidecode
    # networking
    wget curl nmap nettools traceroute dnsutils wol iperf
    # filesystems
    ncdu zfs zfstools ranger lsof ntfs3g
    # hard drive management
    lsscsi hddtemp hdparm perf-tools parted gptfdisk
    # network filesystems
    nfs-utils
    # security
    pass gopass openssl age
    # nix package manager
    nixVersions.nix_2_26
  ];

  boot.kernel.sysctl = {
    # SysRQ is useful when things hang.
    "kernel.sysrq" = 1;
    # Reclaim file pages as often as anon pages.
    "vm.swappiness" = 100;
  };

  # Eanble EarlyOOM
  services.earlyoom = {
    enable = true;
    freeSwapThreshold = 20;
    freeSwapKillThreshold = 10;
  };

  # Setup garbage collector
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # NTP Server
  services.chrony.enable = true;

  # Uptime tracker
  services.uptimed.enable = true;
}