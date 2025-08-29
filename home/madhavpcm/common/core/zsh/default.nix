{ hostSpec, pkgs, lib, ... }:
let
  devDirectory = "~/Dev";
  devNix = "${devDirectory}/nix";
in {
  programs.zsh = {
    enable = true;

    dotDir = ".config/zsh";
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    autosuggestion.enable = true;
    history.size = 10000;
    history.share = true;

    plugins = [
      {
        name = "powerlevel10k-config";
        src = ./p10k;
        file = "p10k.zsh.theme";
      }
      {
        name = "zsh-powerlevel10k";
        src = "${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/";
        file = "powerlevel10k.zsh-theme";
      }
    ] ++ lib.optionals (hostSpec.hostName != "iso") [
      {
        name = "zsh-term-title";
        src = "${pkgs.zsh-term-title}/share/zsh/zsh-term-title/";
      }
      {
        name = "cd-gitroot";
        src = "${pkgs.cd-gitroot}/share/zsh/cd-gitroot";
      }
      {
        name = "zhooks";
        src = "${pkgs.zhooks}/share/zsh/zhooks";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Enable Powerlevel10k instant prompt
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '')
      (lib.mkAfter (lib.readFile ./zshrc))
    ];

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
      extraConfig = ''
        COMPLETION_WAITING_DOTS="true"
      '';
    };

    shellAliases = {
      cat = "bat --paging=never";
      diff = "batdiff";
      rg = "batgrep";
      man = "batman";

      doc = "cd $HOME/documents";
      scripts = "cd $HOME/scripts";
      ts = "cd $HOME/.talon/user/fidget";
      src = "cd $HOME/src";
      edu = "cd $HOME/src/edu";
      wiki = "cd $HOME/sync/obsidian-vault-01/wiki";
      uc = "cd $HOME/src/unmoved-centre";
      l = "eza -lah";
      la = "eza -lah";
      ll = "eza -lh";
      ls = "eza";
      lsa = "eza -lah";

      cnc = "cd ${devNix}/nix-config";
      cns = "cd ${devNix}/nix-secrets";
      cnh = "cd ${devNix}/nixos-hardware";
      cnp = "cd ${devNix}/nixpkgs";

      nfc = "nix flake check";
      ne = "nix instantiate --eval";
      nb = "nix build";
      ns = "nix shell";

      jr = "just rebuild";
      jrt = "just rebuild-trace";
      jl = "just --list";
      jc = "$just check";
      jct = "$just check-trace";

      e = "nvim";
      vi = "nvim";
      vim = "nvim";

      ssh = "TERM=xterm ssh";
    };
  };
}

