# This file defines overlays/custom modifications to upstream packages
#

{ inputs, ... }:

let
  # Adds my custom packages
  # FIXME: Add per-system packages
  #additions = final: prev:
  #  (prev.lib.packagesFromDirectoryRecursive {
  #    callPackage = prev.lib.callPackageWith final;
  #    directory = ../pkgs/common;
  #  });

  linuxModifications = final: prev: prev.lib.mkIf final.stdenv.isLinux { };

  stable-packages = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      inherit (final) system;
      config.allowUnfree = true;
      #      overlays = [
      #     ];
    };
  };

  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
      #      overlays = [
      #     ];
    };
  };

in {
  default = final: prev:
    (linuxModifications final prev) // (stable-packages final prev)
    // (unstable-packages final prev);

}
