{ pkgs, lib, ... }: {
  environment.systemPackages =
    lib.mkAfter [ pkgs.protonvpn-cli pkgs.protonvpn-gui ];
}
