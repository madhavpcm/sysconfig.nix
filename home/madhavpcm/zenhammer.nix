{ pkgs, ... }: {
  imports = [
    common/core

    common/opt/browsers
    common/opt/dev
    common/opt/comms
    common/opt/gaming
    common/opt/media
    common/opt/sops.nix

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
    primary = true;
    x = 0;
  }];
}
