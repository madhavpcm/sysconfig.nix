# Development utilities I want across all systems
{ config, lib, pkgs, hostSpec, ... }:
let
  publicGitEmail = hostSpec.email.gitHub;
  privateGitConfig =
    "${config.home.homeDirectory}/.config/git/gitconfig.private";
in {
  imports = lib.custom.scanPaths ./.;

  home.packages = lib.flatten [
    (pkgs.llama-cpp.override { vulkanSupport = true; })
    (builtins.attrValues {
      inherit (pkgs)
      # Development
        claude-code shaderc direnv delta act yq-go ripgrep nixpkgs-review nmap
        difftastic screen man-pages man-pages-posix gdb lldb;
    })
  ];
  #NOTE: Already enabled earlier, this is just extra config
  programs.git = {
    settings = {
      user = {
        email = publicGitEmail;
        name = hostSpec.handle;
      };
      log.showSignature = "true";
      init.defaultBranch = "main";
      pull.rebase = "true";

    };
    ignores = [ ".direnv" "result" ];
  };

  home.file."${privateGitConfig}".text = ''
    [user]
      name = "${hostSpec.handle}"
      email = ${publicGitEmail}
  '';
}
