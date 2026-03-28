{ config, pkgs, ... }: {
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true; # Creates a 'docker' alias for podman
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Add your user to the podman group
  users.users.${config.hostSpec.username}.extraGroups = [ "podman" ];

  # Install minikube and kubectl
  environment.systemPackages = with pkgs; [ minikube kubectl kubectx ];
}
