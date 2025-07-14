{ inputs, pkgs, lib, ... }: {
  programs.hyprland = { enable = true; };

  environment.systemPackages =
    lib.mkAfter [ inputs.rose-pine-hyprcursor.packages.${pkgs.system}.default ];
}
