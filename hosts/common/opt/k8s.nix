{ config, pkgs, ... }: {
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true; # Creates a 'docker' alias for podman
      defaultNetwork.settings.dns_enabled = true;
    };
    containers.storage.settings = {
      storage = {
        driver = "overlay";
        graphroot =
          "/home/${config.hostSpec.username}/.local/share/containers/storage";
        options.overlay.mount_program =
          "${pkgs.fuse-overlayfs}/bin/fuse-overlayfs";
      };
    };
  };

  # Add your user to the podman group
  users.users.${config.hostSpec.username}.extraGroups = [ "podman" ];

  # Install kubectl
  environment.systemPackages = with pkgs; [
    kubectl
    kubectx
    fuse-overlayfs
    kubectl-cnpg
  ];

  services.k3s.enable = true;
  services.k3s.role = "server";
  services.k3s.extraFlags = toString [ ];
}
