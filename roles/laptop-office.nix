{ pkgs, ... }:

{
  services = {
    # Window manager
    xserver = { 
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.pantheon.enable = true;
      xkb = {
        layout = "hr";
	      variant = "";
      };
    };

    # Audio
    pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Yubikey
    pcscd.enable = true;

    # VPN
    tailscale.enable = true;

    # Printing
    printing.enable = true;

    # OpenSSH tweaks
    openssh.settings.X11Forwarding = true;
  };

  # User Configuration
  users.users.markob = {
    packages = with pkgs; [
      # Development
      vscode xsel bitwarden-cli easyrsa

      # DevOps
      ansible terraform remmina age-plugin-yubikey
      awscli2 cachix direnv tailscale 

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

  programs.firefox.enable = true;
  programs.zsh = {
    promptInit = ''
      export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
      export PATH=$PATH:$HOME/.dotfiles
    '';
  };

  # Additional packages
  environment.systemPackages = with pkgs; [
    # dev tools
    yq gh nodejs ripgrep universal-ctags hcloud 
    # networking
    nebula
    # security
    vault pinentry-curses gnupg
    # smart card daemon
    pcsclite yubikey-manager
    # looks
    adwaita-icon-theme papirus-icon-theme
  ];
}
