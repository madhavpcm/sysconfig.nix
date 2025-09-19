{ config, pkgs, lib, hostSpec, ... }:
let
  devDirectory = "~/src";
  devNix = "${devDirectory}/nix";
in {
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historySize = 10000;
    historyControl = [ "erasedups" "ignoredups" "ignorespace" ];
    
    # Bash-specific settings
    shellOptions = [
      "histappend"
      "checkwinsize"
      "extglob"
      "globstar"
      "checkjobs"
      "autocd"  # cd into directories by just typing the name (bash 4.0+)
    ];

    # Initialize starship prompt (modern alternative to powerlevel10k)
    initExtra = ''
      # Enable starship prompt
      if command -v starship > /dev/null 2>&1; then
        eval "$(starship init bash)"
      fi
      
      # Auto-suggestions (if available)
      if [[ -f /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
      fi
      
      # History settings
      export HISTCONTROL=ignoredups:erasedups
      export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
      
      # Append to history file immediately
      PROMPT_COMMAND="history -a; $PROMPT_COMMAND"
      
      # Custom functions
      # cd to git root (replacement for cd-gitroot plugin)
      cdgr() {
        local git_root=$(git rev-parse --show-toplevel 2>/dev/null)
        if [[ -n "$git_root" ]]; then
          cd "$git_root"
        else
          echo "Not in a git repository"
          return 1
        fi
      }
    '';

    shellAliases = {
      # Overrides and custom aliases
      #-------------Bat related------------
      cat = "bat --paging=never";
      diff = "batdiff";
      rg = "batgrep";
      man = "batman";
      #------------Navigation------------
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
      #------------Nix src navigation------------
      cnc = "cd ${devNix}/nix-config";
      # cns = "cd ${devNix}/nix-secrets";
      cnh = "cd ${devNix}/nixos-hardware";
      cnp = "cd ${devNix}/nixpkgs";
      #-----------Nix commands----------------
      nfc = "nix flake check";
      ne = "nix instantiate --eval";
      nb = "nix build";
      ns = "nix shell";
      #-------------justfiles---------------
      jr = "just rebuild";
      jrt = "just rebuild-trace";
      jl = "just --list";
      jc = "just check";
      jct = "just check-trace";
      #-------------Neovim---------------
      e = "nvim";
      vi = "nvim";
      vim = "nvim";
      #-------------SSH---------------
      ssh = "TERM=xterm ssh";
      #-------------Git Goodness-------------
      # Git aliases (bash doesn't have oh-my-zsh git plugin, so adding common ones)
      g = "git";
      ga = "git add";
      gaa = "git add --all";
      gb = "git branch";
      gba = "git branch -a";
      gc = "git commit -v";
      gca = "git commit -v -a";
      gcam = "git commit -a -m";
      gcb = "git checkout -b";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gd = "git diff";
      gdca = "git diff --cached";
      gl = "git pull";
      glog = "git log --oneline --decorate --graph";
      gp = "git push";
      gst = "git status";
      gsta = "git stash";
      gstp = "git stash pop";
      #-------------Additional useful aliases-------------
      ".." = "cd ..";
      "..." = "cd ../..";
      grep = "grep --color=auto";
      egrep = "egrep --color=auto";
      fgrep = "fgrep --color=auto";
      # Git root navigation function alias
      gr = "cdgr";
    };
  };

  # Add starship for a modern prompt (alternative to powerlevel10k)
  programs.starship = {
    enable = true;
    settings = {
      # Basic starship configuration - customize as needed
      format = "$all$character";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      # Add git branch info
      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
      };
    };
  };

  # Ensure required packages are available
  home.packages = lib.optionals (hostSpec.hostName != "iso") (with pkgs; [
    bat
    eza
    lsd
    starship
    bat-extras.batdiff
    bat-extras.batgrep  
    bat-extras.batman

  ]);
}
