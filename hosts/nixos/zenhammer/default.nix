# #####################################################
#
# zenhammer - Dream build
# NixOS - Ryzen 9 7900x, Radeon 9060 XT, 32 GiB RAM 
#
###################################################### 

{ inputs, config, lib, pkgs, ... }:

{
  imports = lib.flatten [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.stylix.nixosModules.stylix
    (map lib.custom.relativeToRoot [
      # ========== Required Configs ==========
      "hosts/common/core"
      # ========== Optional Configs ==========
      "hosts/common/opt/services/bluetooth.nix" # pipewire and cli controls
      "hosts/common/opt/audio.nix" # pipewire and cli controls
      "hosts/common/opt/gaming.nix" # steam, gamescope, gamemode, and related hardware
      "hosts/common/opt/hyprland.nix" # window manager
      "hosts/common/opt/vpn.nix" # vpn
      "hosts/common/opt/vlc.nix" # media player
      "hosts/common/opt/virt.nix" # vritualization
      "hosts/common/opt/wayland-tools.nix" # wayland components and pkgs not available in home-manager
      # "hosts/common/opt/tailscale.nix" # wrieguard
      "hosts/common/opt/wireguard.nix" # wrieguard
    ])
  ];
  hostSpec = {
    hostName = "zenhammer";
    # useYubikey = lib.mkForce true;
    hdr = lib.mkForce true;
    persistFolder =
      "/persist"; # added for "completion" because of the disko spec that was used even though impermanence isn't actually enabled here yet.
  };

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot = {
        enable = true;
        configurationLimit = lib.mkDefault 7;
      };
    };
  };

  stylix = {
    enable = true;
    #image = (lib.custom.relativeToRoot "assets/wallpapers/zen-01.png");
    base16Scheme =
      "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
    opacity = {
      applications = 1.0;
      terminal = 1.0;
      desktop = 1.0;
      popups = 0.8;
    };
    polarity = "dark";
    # program specific exclusions
    #targets.foo.enable = false;
  };

  networking = {
    hostName = "zenhammer"; # Define your hostname.
    networkmanager.enable = true;
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 80 443 22 ];
    firewall.trustedInterfaces = [ "virbr0" ];
  };

  time.timeZone = "Asia/Kolkata";

  environment.systemPackages = with pkgs; [
    openrgb-with-all-plugins
    v4l-utils
  ];
  services = {
    hardware.openrgb.enable = true;
    openssh.enable = true;
    printing.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
    libinput.enable = false; # Touchpad not needed in desktop
    flatpak = { enable = true; };
    xserver = {
      enable = true;
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
      };
      desktopManager.gnome.enable = true;
      excludePackages = with pkgs; [ xterm ];
    };
    udev = {
      packages = with pkgs; [ gnome-settings-daemon ];
      extraRules = ''
        # Intel RAPL energy usage file
        			ACTION=="add", SUBSYSTEM=="powercap", KERNEL=="intel-rapl:0", RUN+="${pkgs.coreutils}/bin/chmod 444 /sys/class/powercap/intel-rapl/intel-rapl:0/energy_uj"

        # DeepCool HID raw devices
        			SUBSYSTEM=="hidraw", ATTRS{idVendor}=="3633", MODE="0666"

        # CH510 MESH DIGITAL
        			SUBSYSTEM=="hidraw", ATTRS{idVendor}=="34d3", ATTRS{idProduct}=="1100", MODE="0666"
        			'';
    };
  };
  # RGB controls

  hardware.graphics.enable = true;
  #hardware.graphics.package = lib.mkForce pkgs.unstable.mesa.drivers;
  hardware.amdgpu.initrd.enable = true; # load amdgpu kernelModules in stage 1.
  hardware.amdgpu.opencl.enable =
    true; # OpenCL support - general compute API for gpu
  hardware.amdgpu.amdvlk.enable = true; # additional, alternative drivers

  users.users.madhavpcm = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ tree curl git ];
  };

  programs.dconf.profiles.user.databases = [{
    lockAll = true;
    settings = {
      "org/gnome/desktop/interface" = { accent-color = "red"; };
      "org/gnome/desktop/input-sources" = { xkb-options = [ "ctrl:nocaps" ]; };
    };
  }];

  #nix.settings.experimental-features = [ "nix-command" "flakes" ];
  #nix.nixPath = [
  #  "nixos-config=/home/madhavpcm/Dev/sysconf.nix/configuration.nix"
  #  "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos"
  #  "/nix/var/nix/profiles/per-user/root/channels"
  #];
  system.stateVersion = "25.05"; # Did you read the comment?
  boot.kernelPackages = pkgs.linuxPackages_latest;

}

