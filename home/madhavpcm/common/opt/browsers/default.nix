{ pkgs, ... }: {
  imports =
    [ (import ./zen.nix { inherit pkgs; }) ./chromium.nix ./firefox.nix ];
}

