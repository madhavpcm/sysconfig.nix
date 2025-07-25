{ pkgs, ... }: {

  home.packages = builtins.attrValues {
    inherit (pkgs) telegram-desktop discord;
    inherit (pkgs.unstable) signal-desktop;
  };
}
