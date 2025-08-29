# Core functionality for every nixos host
{ config, lib, ... }: {
  # Database for aiding terminal-based programs
  environment.enableAllTerminfo = true;
  # Enable firmware with a license allowing redistribution
  hardware.enableRedistributableFirmware = true;

  # This should be handled by config.security.pam.sshAgentAuth.enable
  security.sudo.extraConfig = ''
    Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
    Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
    Defaults timestamp_timeout=120 # only ask for password every 2h
    # Keep SSH_AUTH_SOCK so that pam_ssh_agent_auth.so can do its magic.
    Defaults env_keep+=SSH_AUTH_SOCK
  '';

  #
  # ========== Nix Helper ==========
  #
  # Provide better build output and will also handle garbage collection in place of standard nix gc (garbace collection)
  environment.etc.hosts.mode = "0644";
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 14d --keep 7";
    flake = "/home/user/${config.hostSpec.home}/nix-config";
  };

  services.kanata = {
    enable = true;
    keyboards.default = {
      # Optional: define the device, or use default input grabbing
      # device = "/dev/input/by-id/..."; # Or leave unset for all keyboards
      config = ''
        ;; Caps to escape/control configuration for Kanata
        (defsrc
          f1   f2   f3   f4   f5   f6   f7   f8   f9   f10   f11   f12
          caps
        )

        ;; Definine two aliases, one for esc/control to other for function key
        (defalias
          escctrl (tap-hold 100 100 esc lctl)
        )

        (deflayer base
          brdn  brup  _    _    _    _   prev  pp  next  mute  vold  volu
          @escctrl
        )

        (deflayer fn
          f1   f2   f3   f4   f5   f6   f7   f8   f9   f10   f11   f12
          @escctrl
        )
      '';
    };
  };

  # services.keyd = {
  #   enable = true;
  #   keyboards.default = {
  #     ids = [ "*" ]; # Apply to all keyboards
  #     settings = {
  #       main = {
  #         capslock =
  #           "noop"; # TODO(keyboard): should change this to be overload(\, |) to match moonlander
  #         numlock = "noop"; # numlock state on by default via hyprland config
  #       };
  #     };
  #   };
  # };

  #
  # ========== Localization ==========
  #
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "Asia/Kolkata";
}
