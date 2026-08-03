{ pkgs, lib, config, inputs, ... }: {

  environment.systemPackages = lib.mkAfter [ pkgs.protonvpn-gui ];
  services.tailscale.enable = true;
}
