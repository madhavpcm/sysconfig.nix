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
    inputs.common.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-ssd
  ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    efi.efiSysMountPoint = "/boot";
    loader = {
      efi = {
        efi.canTouchEfiVariables = true;
        efi.efiSysMountPoint = "/boot";
      };
      systemd-boot.enable = true;
    };
  };
  environment.systemPackages = with pkgs;
    import ./sys-packages.nix { inherit pkgs; };

  networking = {
    hostName = "nixos-zenhammer"; # Define your hostname.
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "Asia/Kolkata";

  services = {
    openssh.enable = false;
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

  users.users.madhavpcm = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [ tree curl git ];
  };

  programs.firefox.enable = true;
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

