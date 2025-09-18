# User config applicable only to nixos
{ inputs, config, lib, pkgs, ... }:
let
  hostSpec = config.hostSpec;
  ifTheyExist = groups:
    builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  # Decrypt password to /run/secrets-for-users/ so it can be used to create the user
  sopsHashedPasswordFile = lib.optionalString (!config.hostSpec.isMinimal)
    config.sops.secrets."passwords/${hostSpec.username}".path;
in {
  users.mutableUsers =
    false; # Only allow declarative credentials; Required for password to be set via sops during system activation!
  users.users.${hostSpec.username} = {
    home = "/home/${hostSpec.username}";
    isNormalUser = true;
    hashedPasswordFile = sopsHashedPasswordFile; # Blank if sops is not working.
    group = "${hostSpec.username}";

    extraGroups = lib.flatten [
      "wheel"
      (ifTheyExist [
        "audio"
        "video"
        "docker"
        "git"
        "networkmanager"
        "scanner" # for print/scan"
        "lp" # for print/scan"
      ])
    ];
  };

  # No matter what environment we are in we want these tools for root, and the user(s)
  programs.git.enable = true;
} // lib.optionalAttrs (inputs ? "home-manager") {

  # Setup p10k.zsh for root
  home-manager.users.root = lib.optionalAttrs (!hostSpec.isMinimal) {
    home.stateVersion = "25.05"; # Avoid error
    programs.zsh = {
      enable = true;
      plugins = [{
        name = "powerlevel10k-config";
        src = lib.custom.relativeToRoot
          "home/${hostSpec.username}/common/core/zsh/p10k";
        file = "p10k.zsh";
      }];
    };
  };
}
