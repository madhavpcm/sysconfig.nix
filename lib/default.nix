# # Library to traverse all non default.nix files recursively
{ lib, ... }:

let inherit (lib) strings attrsets;
in {
  relativeToRoot = lib.path.append ../.;

  scanPaths = dir:
    builtins.map (name: "${dir}/${name}") (builtins.attrNames
      (attrsets.filterAttrs (name: type:
        type == "directory"
        || (name != "default.nix" && strings.hasSuffix ".nix" name))
        (builtins.readDir dir)));
}

