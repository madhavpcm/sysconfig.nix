# Development utilities I want across all systems
{ config, lib,  pkgs, ... }:
let
  hostSpec = config.hostSpec;
  publicGitEmail = hostSpec.email.gitHub;
  privateGitConfig =
    "${config.home.homeDirectory}/.config/git/gitconfig.private";
in {
  imports = lib.custom.scanPaths ./.;

  home.packages = lib.flatten [
    (builtins.attrValues {
      inherit (pkgs)
      # Development
        direnv delta # diffing
        # github workflows
        act yq-go # Parser for Yaml and Toml Files, that mirrors jq
        # nix
        ripgrep nixpkgs-review nmap difftastic screen man-pages man-pages-posix
        # Debugging
        gdb lldb;
    })
  ];

  #NOTE: Already enabled earlier, this is just extra config
  programs.git = {
    userName = config.hostSpec.handle;
    userEmail = publicGitEmail;
    extraConfig = {
      log.showSignature = "true";
      init.defaultBranch = "main";
      pull.rebase = "true";

    };
    ignores = [ ".direnv" "result" ];
  };

  home.file."${privateGitConfig}".text = ''
    [user]
      name = "${config.hostSpec.handle}"
      email = ${publicGitEmail}
  '';
}
