{ pkgs, ... }: {
  fonts = {
    fontconfig.enable = true;
    fontDir.enable = true;
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      nerd-fonts.symbols-only # Highly recommended for icons/symbols
      # Add other fonts here
    ];
  };
  home.packages = builtins.attrValues {
    inherit (pkgs) noto-fonts corefonts meslo-lgs-nf;
    inherit (pkgs.nerd-fonts) fira-code;
  };
}
