{ config, pkgs, lib, ... }:
let
  nixosTarball = fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-24.11.tar.gz";
  };
  nixvim = import (builtins.fetchGit {
    url = "https://github.com/nix-community/nixvim";
    ref = "nixos-24.11";
  });
in
{
  imports = [
    <nixos-hardware/lenovo/thinkpad/t14>
    ./hardware-configuration.nix
    <agenix/modules/age.nix>
    nixvim.nixosModules.nixvim
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import nixosTarball {
        config = config.nixpkgs.config;
      };
    };
    allowUnfree = true;
  };

  # System Boot Configuration
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelParams = [ "mem_sleep_default=deep" ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernel.sysctl = {
      "kernel.sysrq" = 1;
      "vm.swappiness" = 100;
    };
  };

  # Swap Configuration
  swapDevices = [ { device = "/var/lib/swapfile"; size = 4 * 1024; } ];

  # Networking
  networking = {
    hostName = "nixos";
    extraHosts = ''
      88.198.54.19 torvion
      49.13.212.18 ghosteye
    '';
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

  time.timeZone = "Europe/Zagreb";

  # Services
  services = {
    xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.pantheon.enable = true;
      xkb = {
        layout = "hr";
        variant = "";
      };
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    printing.enable = true;
    openssh.enable = true;
    openssh.settings.X11Forwarding = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    sane.enable = true;
    opengl = {
      enable = true;
      extraPackages = with pkgs; [
        onevpl-intel-gpu
      ];
    };
    pulseaudio.enable = false;
  };

  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  users.extraGroups.docker.members = [ "markob" ];

  # User Configuration
  users.users.markob = {
    isNormalUser = true;
    description = "Marko Burcul";
    extraGroups = [ "networkmanager" "wheel" "root" "audio" "scanner" "lp" ];
    useDefaultShell = true;
    packages = with pkgs; [
      # Development
      vscode xsel bitwarden-cli easyrsa

      # DevOps
      ansible terraform docker docker-compose
      awscli2 

      # Python and its packages
      python3Full

      # System Utilities
      earlyoom sof-firmware

      # Communication
      discord element-desktop

      # Drawing and Design
      drawing

      # Miscellaneous
      try toss gnumake42
    ];
  };

  users.defaultUserShell = pkgs.zsh;
  
  # Disable password for root
  security.sudo.wheelNeedsPassword = false;

  # Programs
  programs = {
    firefox.enable = true;
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
      enableBashCompletion = true;
      histSize = 5000;
      shellAliases = {
        v = "nvim";
        vi = "nvim";
        vim = "nvim";
        g = "git status";
        gc = "git commit -s -S";
      };
      promptInit = ''
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        export PATH=$PATH:$HOME/.dotfiles
        export VAULT_ADDR="https://vault-api.infra.status.im:8200"
        export VAULT_CLIENT_CERT=ansible/files/vault-client-user.crt
        export VAULT_CACERT=ansible/files/vault-ca.crt
        export VAULT_CLIENT_KEY=ansible/files/vault-client-user.key
      '';
      ohMyZsh = {
        enable = true;
          theme = "dst";
          plugins = [
            "git"
            "colorize"
            "dirhistory"
            "dirpersist"
            "fzf"
            "zsh-interactive-cd"
          ];
      };
    };
    fzf.fuzzyCompletion = true;
    nixvim = {
      enable = true;
      opts = {
        relativenumber = true;
        shiftwidth = 2;
        autochdir = true;
        splitright = true;
        hidden = true;
        cursorline = true;
        number = true;
        showmatch = true;
        scrolloff = 3;
        encoding = "utf-8";
        autoindent = true;
        expandtab = true;
        tabstop = 4;
        softtabstop = 4;
        ignorecase = true;
        smartcase = true;
        undofile = true;
        undodir = "~/.config/nvim/undo//";
        undolevels = 100;
        undoreload = 1000;
      };
      extraPlugins = with pkgs.vimPlugins; [
        vim-nix fzf-vim lightline-vim nerdtree
      ];
      colorschemes.catppuccin.enable = true;
    };
    gnupg.agent = {
      enableSSHSupport = true;
      enable = true;
      enableExtraSocket = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
  };

  # Environment
  environment.systemPackages = with pkgs; [
    # utilities
    file zsh bash man-pages sudo bc pv rename uptimed lsb-release
    # building
    gnumake gcc autoconf automake patchelf
    unzip zip envsubst entr
    # processes
    dtach pstree killall sysstat
    # monitoring
    htop iotop iftop multitail ps
    # dev tools
    jq tmux fzf silver-searcher
    git qrencode sqlite yq gh nodejs 
    ripgrep universal-ctags hcloud 
    # hardware tools
    pciutils lm_sensors acpi pmutils usbutils dmidecode
    # networking
    wget curl nmap nettools traceroute dnsutils wol iperf
    nebula
    # filesystems
    ncdu zfs zfstools ranger lsof ntfs3g
    # hard drive management
    lsscsi hddtemp hdparm perf-tools parted gptfdisk
    # network filesystems
    nfs-utils transmission_4-qt
    # security
    pass gopass openssl age age-plugin-yubikey vault
    pinentry-curses gnupg
    (pkgs.callPackage <agenix/pkgs/agenix.nix> {})
  ];

  nix = {
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than +5";
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # System Version
  system.stateVersion = "24.11";
}

