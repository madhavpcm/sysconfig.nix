{ pkgs, ... }: {
  # Pre 25.11
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  system.activationScripts.gdm_config = {
    deps = [ "specialfs" ];
    text = ''
      MONITORS_CONF_FILE=/etc/nixos/data/monitors.xml
      GDM_CONF_PATH=/run/gdm/.config
      if [ ! -d $GDM_CONF_PATH ]; then
        mkdir -p $GDM_CONF_PATH
      fi
      if [ -f $MONITORS_CONF_FILE ]; then
        cp -rf $MONITORS_CONF_FILE $GDM_CONF_PATH
        chown gdm:gdm  $GDM_CONF_PATH/$(basename $MONITORS_CONF_FILE)
        chmod 644 $GDM_CONF_PATH/$(basename $MONITORS_CONF_FILE)
      fi
    '';
  };

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

