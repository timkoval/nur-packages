{
  description = "My personal NUR repository";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      # Full imported set: { openspec = pkg; ... }
      legacyPackages = forAllSystems (system: import ./default.nix {
        pkgs = import nixpkgs { inherit system; };
      });

      # NEW: Extract only the *derivations* from default.nix
      packages = forAllSystems (system:
        let
          imported = import ./default.nix {
            pkgs = import nixpkgs { inherit system; };
          };
        in
        nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) imported
      );
    };
}
