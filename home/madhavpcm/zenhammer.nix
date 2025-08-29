{ lib, hostSpec, ... }: 
{
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

  home.activation.debugHostSpec = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${hostSpec.home}
    echo '${builtins.toJSON hostSpec}' > ${hostSpec.home}/hostSpec-debug.json
  '';
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
