{ pkgs, lib, ... }: {
  environment.systemPackages = lib.mkAfter [ pkgs.networkmanagerapplet ];
}
