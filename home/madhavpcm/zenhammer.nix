{ pkgs, ... }: {
  imports = [
    common/core

    common/opt/browsers
    common/opt/desktops # default is hyprland
    common/opt/dev
    common/opt/comms
    common/opt/gaming
    common/opt/media
    common/opt/tools

    common/opt/xdg.nix # file associations
  ];

  #  ------ 
  # | DP-1 |
  #  ------ 
  monitors = [{
    name = "DP-1";
    width = 3840;
    height = 2160;
    refreshRate = 60;
    x = 0;
  }];
}
