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
          "colorize"
          "dirhistory"
          "dirpersist"
          "zsh-interactive-cd"
        ];
    };
  };

  # Enable fzf
  programs.fzf.fuzzyCompletion = true;

  users.defaultUserShell = pkgs.zsh;

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