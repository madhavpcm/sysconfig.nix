{ config, inputs, lib, ... }:

let
  sopsBase = "${builtins.toString inputs.nix-secrets}/sops";
  username = config.home.username;
  userFile = "${sopsBase}/users/${username}.yaml";
in {
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = userFile;

    secrets = {
      "tokens/github" = { path = "${config.xdg.configHome}/gh/token"; };

      "env/PRIVATE_DOTENV" = {
        path = "${config.home.homeDirectory}/.private.env";
      };
    };
  };
}

