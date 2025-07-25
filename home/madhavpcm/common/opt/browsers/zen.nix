{ pkgs, ... }: {
  systemd.services.install-flatpaks = {
    description = "Install Zen Browser via Flatpak";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "flatpak-system-helper.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "install-flatpaks" ''
        set -e
        ${pkgs.flatpak}/bin/flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        ${pkgs.flatpak}/bin/flatpak install -y --noninteractive flathub app.zen_browser.zen
      '';
    };
  };
}
