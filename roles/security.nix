{ pkgs, config, channels, ... }:

{

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
    };
  };

  # Enable GnuPG agent for keys.
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    enableBrowserSocket = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  # This allows using SSH keys exclusively, instead of passwords, for instance on remote machines.
  security.pam.sshAgentAuth.enable = true;

  # Install Agenix CLI tool.
  environment.systemPackages = [
    channels.agenix.packages.${pkgs.system}.default
  ];

}