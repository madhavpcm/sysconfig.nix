{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # Core Wayland utilities
    wayland
    wlroots
    libinput

    # Session and protocol utilities
    xwayland
    xdg-utils
    xdg-desktop-portal
    xdg-desktop-portal-wlr

    # Clipboard and input
    wl-clipboard
    grim        # screenshot
    slurp       # region selector
    kanshi      # output profiles
    wtype       # virtual keyboard input
    swww

    # Useful for debugging Wayland sessions
    wayland-utils
  ];
}
