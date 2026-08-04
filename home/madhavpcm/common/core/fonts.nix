{ pkgs, ... }: {
  #fonts = {
  #  fontconfig.enable = true;
  #  fontDir.enable = true;
  #  enableDefaultPackages = true;
  #};
  home.packages = builtins.attrValues {
    inherit (pkgs) noto-fonts corefonts meslo-lgs-nf;
    inherit (pkgs.nerd-fonts) fira-code;
  };
}
