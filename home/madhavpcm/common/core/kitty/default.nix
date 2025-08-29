{
  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;

    settings = {
      scrollback_lines = 10000;
    };
    extraConfig = builtins.readFile ./kitty.conf;
  };
}
