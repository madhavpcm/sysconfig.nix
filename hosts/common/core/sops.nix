{ config, inputs, lib, ... }:

let
  sopsBase = "${builtins.toString inputs.nix-secrets}/sops";
  hostFile = "${sopsBase}/hosts/${config.hostSpec.hostName}.yaml";
  sharedFile = "${sopsBase}/shared/global.yaml";
in {
  imports = [ inputs.sops-nix.nixosModules.sops ];

  sops = {
    defaultSopsFile = hostFile;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    validateSopsFiles = true;

    secrets = lib.mkMerge [
      {
        "keys/age" = {
          path = "${config.hostSpec.home}/.config/sops/age/keys.txt";
          owner = config.users.users.${config.hostSpec.username}.name;
          group = config.users.users.${config.hostSpec.username}.group;
        };
      }

      {
        "passwords/${config.hostSpec.username}" = {
          sopsFile = sharedFile;
          neededForUsers = true;
        };
      }

      { "env/HOST_API_KEY" = { sopsFile = hostFile; }; }
    ];
  };
}
