{ lib, pkgs, hostSpec, ... }:

let
  platform = "nixos";
in
{
  imports = lib.flatten [
    (map lib.custom.relativeToRoot [
      "modules/home-manager"
    ])
    ./zsh
    ./kitty

    ./bash.nix
    ./bat.nix
    ./direnv.nix
    ./fonts.nix
    ./git.nix
    ./screen.nix
    ./zoxide.nix
  ];

  services.ssh-agent.enable = true;

  home = {
    username = lib.mkDefault hostSpec.username;
    homeDirectory = lib.mkDefault hostSpec.home;
    stateVersion = lib.mkDefault "25.05";
    sessionPath = [ "$HOME/.local/bin" "$HOME/scripts/talon_scripts" ];
    sessionVariables = {
      FLAKE = "$HOME/src/nix/nix-config";
      SHELL = "zsh";
      TERM = "kitty";
      TERMINAL = "kitty";
      VISUAL = "nvim";
      EDITOR = "nvim";
    };
    preferXdgDirectories = true;
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${hostSpec.home}/.desktop";
      documents = "${hostSpec.home}/docs";
      download = "${hostSpec.home}/downloads";
      music = "${hostSpec.home}/media/audio";
      pictures = "${hostSpec.home}/media/images";
      videos = "${hostSpec.home}/media/video";

      extraConfig = {
        XDG_PUBLICSHARE_DIR = "/var/empty";
        XDG_TEMPLATES_DIR = "/var/empty";
      };
    };
  };

  home.packages = let
    json5-jq = pkgs.stdenv.mkDerivation {
      name = "json5-jq";
      src = pkgs.fetchFromGitHub {
        owner = "wader";
        repo = "json5.jq";
        rev = "ac46e5b58dfcdaa44a260adeb705000f5f5111bd";
        sha256 = "sha256-xBVnbx7L2fhbKDfHOCU1aakcixhgimFqz/2fscnZx9g=";
      };
      dontBuild = true;
      installPhase = ''
        mkdir -p $out/share
        cp json5.jq $out/share/json5.jq
      '';
    };

    jq5 = pkgs.writeShellScriptBin "jq5" ''
      declare -a JQ_OPTS=()
      declare -a QUERY_PARTS=()
      while [ $# -gt 1 ]; do
        if [[ $1 == -* ]]; then
          JQ_OPTS+=("$1")
        else
          QUERY_PARTS+=("$1")
        fi
        shift
      done
      FILE="$1"
      QUERY="$(printf "%s " "''${QUERY_PARTS[@]}")"
      if [ ''${#QUERY_PARTS[@]} -eq 0 ]; then
        jq -Rs -L "${json5-jq}/share/" "''${JQ_OPTS[@]}" 'include "json5"; fromjson5' "$FILE"
      else
        jq -Rs -L "${json5-jq}/share/" "''${JQ_OPTS[@]}" "include \"json5\"; fromjson5 | $QUERY" "$FILE"
      fi
    '';

  in [ jq5 ] ++ builtins.attrValues {
    inherit (pkgs) 
      copyq coreutils curl eza dust fd findutils fzf jq nix-tree neofetch ncdu
      pciutils pfetch pre-commit p7zip ripgrep steam-run usbutils tree unzip
      unrar wev wget xdg-utils xdg-user-dirs yq-go zip
    ;
  };

  nix = {
    package = lib.mkDefault pkgs.nix;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  # Debug hostSpec
  home.activation.debugHostSpec = lib.hm.dag.entryAfter ["writeBoundary"] ''
    mkdir -p ${hostSpec.home}
    echo '${builtins.toJSON hostSpec}' > ${hostSpec.home}/hostSpec-debug.json
  '';
}
