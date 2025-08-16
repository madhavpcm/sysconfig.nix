{
  description = "sysconfig.nix configuration by madhavpcm";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    # The next two are for pinning to stable vs unstable regardless of what the above is set to
    # This is particularly useful when an upcoming stable release is in beta because you can effectively
    # keep 'nixpkgs-stable' set to stable for critical packages while setting 'nixpkgs' to the beta branch to
    # get a jump start on deprecation changes.
    # See also 'stable-packages' and 'unstable-packages' overlays at 'overlays/default.nix"
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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

    # vim4LMFQR!
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
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
    stylix.url = "github:danth/stylix/release-25.05";
    rose-pine-hyprcursor.url = "github:ndom91/rose-pine-hyprcursor";
    nix-secrets = {
      url =
        "git+ssh://git@github.com/madhavpcm/nix-sops.git?ref=main&shallow=1";
      flake = false;
    };

  };

  outputs = { self, nixpkgs, home-manager, sops-nix, ... }@inputs:
    let
      inherit (self) outputs;

      # Extend lib file for custom parsing
      lib = nixpkgs.lib.extend
        (self: super: { custom = import ./lib { inherit (nixpkgs) lib; }; });

      # Architectures
      forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" ];
    in {
      # Overlays: modifications/overrides to upstream packages
      overlays = import ./overlays { inherit inputs; };
      homeConfigurations = {
         "madhavpcm@zenhammer" = home-manager.lib.homeManagerConfiguration {
           modules = [ ./home/madhavpcm/zenhammer.nix ];
           pkgs = nixpkgs.legacyPackages.x86_64-linux;
           extraSpecialArgs = {inherit inputs outputs;};
         };
      };

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

      # DevShell: Custom shell for bootstrapping on new hosts, modifying nix-config, and secrets management
      devShells = forAllSystems (system:
        import ./shell.nix {
          pkgs = nixpkgs.legacyPackages.${system};
          checks = self.checks.${system};
        });

    };
}

