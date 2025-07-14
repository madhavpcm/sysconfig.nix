{ pkgs, ... }: {
  # Pre 25.11
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # As of 25.11
  #services.displayManager.gdm.enable = true;
  #services.desktopManager.gnome.enable = true;

  # Common
  services.udev.packages = with pkgs; [ gnome-settings-daemon ];
  programs.dconf.profiles.user.databases = [{
    lockAll = true;
    settings = {
      "org/gnome/desktop/interface" = { accent-color = "red"; };
      "org/gnome/desktop/input-sources" = { xkb-options = [ "ctrl:nocaps" ]; };
    };
  }];
}

