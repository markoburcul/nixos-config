{ pkgs, ... }:

{
  # Shell
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    enableBashCompletion = true;
    ohMyZsh = {
      enable = true;
        theme = "fletcherm";
        plugins = [
	        "git"
          "direnv"
          "colorize"
          "dirhistory"
          "dirpersist"
          "zsh-interactive-cd"
        ];
    };
    interactiveShellInit = ''
      if [ -f /etc/zprofile.local ]; then
        . /etc/zprofile.local
      fi
    '';
  };

  # Enable fzf
  programs.fzf.fuzzyCompletion = true;

  users.defaultUserShell = pkgs.zsh;

  # Set system wide zprofile
  environment.etc."zprofile.local".text = builtins.readFile "${toString ./../files/zsh/zprofile}";

  # Editor
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  # Editor
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}