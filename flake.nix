{
  description = "sysconfig.nix configuration by madhavpcm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    # The next two are for pinning to stable vs unstable regardless of what the above is set to
    # This is particularly useful when an upcoming stable release is in beta because you can effectively
    # keep 'nixpkgs-stable' set to stable for critical packages while setting 'nixpkgs' to the beta branch to
    # get a jump start on deprecation changes.
    # See also 'stable-packages' and 'unstable-packages' overlays at 'overlays/default.nix"
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Declarative vms using libvirt
    nixvirt = {
      url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llama-cpp = {
      url = "github:ggml-org/llama.cpp";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hf-nix = {
      url = "github:huggingface/hf-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # vim4LMFQR!
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
      #url = "github:nix-community/nixvim";
      #inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # Pre-commit
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming
    stylix.url = "github:danth/stylix/release-25.11";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    nix-secrets = {
      url =
        "git+ssh://git@github.com/madhavpcm/nix-sops.git?ref=main&shallow=1";
      flake = false;
    };

  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, home-manager
    , sops-nix, ... }@inputs:
    let
      inherit (self) outputs;

      # Extend lib file for custom parsing
      lib = nixpkgs.lib.extend
        (self: super: { custom = import ./lib { inherit (nixpkgs) lib; }; });
      customLib = import ./lib { inherit (nixpkgs) lib; };

      # Architectures
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];

      # helper: pick pkgs for a given system
      pkgsFor = system: {
        default = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnfree = true;
        };
        stable = import nixpkgs-stable {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnfree = true;
        };
        unstable = import nixpkgs-unstable {
          inherit system;
          overlays = [ self.overlays.default ];
          config.allowUnfree = true;
        };
      };
    in {
      # Overlays: modifications/overrides to upstream packages
      overlays = import ./overlays { inherit inputs; };

      ## Packages: expose packages externally
      #packages = forAllSystems (system:
      #  let
      #    pkgs = import nixpkgs {
      #      inherit system;
      #      overlays = [ self.overlays.default ];
      #    };
      #  in nixpkgs.lib.packagesFromDirectoryRecursive {
      #    callPackage = nixpkgs.lib.callPackageWith pkgs;
      #    directory = ./pkgs/common;
      #  });

      # Formatter: nix fmt
      formatter = forAllSystems
        (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      # Hosts: configurations to be applied for each machine host
      nixosConfigurations = builtins.listToAttrs (map (host: {
        name = host;
        value = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs lib;
            isDarwin = false;
          };
          modules = [ ./hosts/nixos/${host} ];
        };
      }) (builtins.attrNames (builtins.readDir ./hosts/nixos)));

      foo = builtins.trace
        "Config: ${self.nixosConfigurations.zenhammer.config.hostSpec}";
      homeConfigurations = let
        system = "x86_64-linux";
        pkgs-sets = pkgsFor system;
      in {
        "madhavpcm@zenhammer" = home-manager.lib.homeManagerConfiguration {
          modules = [
            ./home/madhavpcm/zenhammer.nix
            ./modules/common/host-spec.nix
            # Configure nixpkgs for Home Manager
            { nixpkgs.config.allowUnfree = true; }
          ];
          pkgs = pkgs-sets.default;
          extraSpecialArgs = {
            inherit inputs;
            outputs = self.outputs;
            lib = lib.extend (_: _: inputs.home-manager.lib);
            hostSpec = self.nixosConfigurations.zenhammer.config.hostSpec;
            # Make stable and unstable packages available
            pkgs-stable = pkgs-sets.stable;
            pkgs-unstable = pkgs-sets.unstable;
            # Pass user configuration from NixOS
            nixosUsers = self.nixosConfigurations.zenhammer.config.users.users;
          };
        };
      };

      # DevShell: Custom shell for bootstrapping on new hosts, modifying nix-config, and secrets management
      devShells = forAllSystems (system:
        import ./shell.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          checks = self.checks.${system};
        });

    };
}
