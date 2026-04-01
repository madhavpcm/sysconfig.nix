# Development utilities I want across all systems
{ config, lib, pkgs, hostSpec, antigravity, ... }:
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
        delta direnv difftastic sshfs ripgrep screen man-pages nixpkgs-review
        man-pages-posix
        # k8s
        mirrord
        # C/CPP
        gcc gnumake shaderc gdb lldb
        # Py
        python3 act nmap
        # Js
        bun nodejs_22
        # Go
        opencode claude-code go delve;
    })
    (builtins.attrValues { inherit (antigravity) google-antigravity; })
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
