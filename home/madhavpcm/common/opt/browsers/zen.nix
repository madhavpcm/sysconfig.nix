{ pkgs, ... }: {
  systemd.services.install-flatpaks = {
    description = "Install flatpak apps";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "install-flatpaks" ''
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        ${pkgs.flatpak}/bin/flatpak install -y flathub com.github.unrud.zen_browser
      '';
    };
  };
}

