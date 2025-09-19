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
      # Your Powerlevel10k theme and config
      {
        name = "powerlevel10k-config";
        src = ./p10k; # Assumes you have a ./p10k directory with your p10k.zsh
        file = "p10k.config"; # The file to source, often .p10k.zsh or p10k.zsh
      }
      {
        name = "zsh-powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }

      # Your other external plugins
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh-plugins/you-should-use/you-should-use.plugin.zsh";
      }
    ] ++ lib.optionals (hostSpec.hostName != "iso") [
      # Conditionally add fzf history search
      {
        name = "zsh-fzf-history-search";
        src = pkgs.zsh-fzf-history-search;
        file = "share/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh";
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
      grep = "batgrep";
      man = "batman";

      doc = "cd $HOME/documents";
      scripts = "cd $HOME/scripts";
      ts = "cd $HOME/.talon/user/fidget";
      src = "cd $HOME/src";
      edu = "cd $HOME/src/edu";
      wiki = "cd $HOME/sync/obsidian-vault-01/wiki";
      uc = "cd $HOME/src/unmoved-centre";
      l = "lsd -lah";
      la = "lsd -lah";
      ll = "lsd -lh";
      ls = "lsd ";
      lsa = "lsd -lah";

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

