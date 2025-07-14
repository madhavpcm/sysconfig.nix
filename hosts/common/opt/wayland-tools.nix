{ pkgs, lib, ... }: {
  # general packages related to wayland
  environment.systemPackages = lib.mkAfter [
    pkgs.grim # screen capture component, required by flameshot
    pkgs.waypaper # wayland packages(nitrogen analog for wayland)
    pkgs.swww # backend wallpaper daemon required by waypaper
  ];
}
