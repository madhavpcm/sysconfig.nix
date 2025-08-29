# hosts level sops. see home/[user]/common/optional/sops.nix for home/user level

{ pkgs, lib, inputs, config, ... }:
let 
  sopsFolder = (builtins.toString inputs.nix-secrets) + "/sops";
  homeDirectory = config.home.homeDirectory;
in {
  #the import for inputs.sops-nix.nixosModules.sops is handled in hosts/common/core/default.nix so that it can be dynamically input according to the platform
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    #    defaultSopsFile = "${secretsFile}";
    defaultSopsFile = "${sopsFolder}/secret.yaml";
    validateSopsFiles = false;
    age = {
      # automatically import host SSH keys as age keys
      sshKeyPaths = [ "/mnt/etc/ssh/ssh_host_ed25519_key" ];
    };
    # secrets will be output to /run/secrets
    # e.g. /run/secrets/msmtp-password
    # secrets required for user creation are handled in respective ./users/<username>.nix files
    # because they will be output to /run/secrets-for-users and only when the user is assigned to a host.
  };

  # For home-manager a separate age key is used to decrypt secrets and must be placed onto the host. This is because
  # the user doesn't have read permission for the ssh service private key. However, we can bootstrap the age key from
  # the secrets decrypted by the host key, which allows home-manager secrets to work without manually copying over
  # the age key.
  sops.secrets = lib.mkMerge [{
    # These age keys are are unique for the user on each host and are generated on their own (i.e. they are not derived
    # from an ssh key).

    "keys/${config.home.username}" = {
      owner = config.users.users.${config.home.username}.name;
      inherit (config.users.users.${config.home.username}) group;
      # We need to ensure the entire directory structure is that of the user...
      path = "${homeDirectory}/.config/sops/age/keys.txt";
    };
    # extract password/username to /run/secrets-for-users/ so it can be used to create the user
    "passwords/${config.home.username}" = {
      sopsFile = "${sopsFolder}/secrets.yaml";
      neededForUsers = true;
    };
  }];
}
