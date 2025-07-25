{ pkgs, ... }: {
  home.packages = builtins.attrValues {
    inherit (pkgs)

      ffmpeg vlc mpv handbrake audacity gimp obs-studio;
    inherit (pkgs.stable) calibre;
  };
}
