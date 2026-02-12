{ pkgs, lib, ... }: {
  environment.systemPackages = lib.mkAfter [ pkgs.protonvpn-gui ];
}
