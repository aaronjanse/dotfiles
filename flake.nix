{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    juliaFlake.url = "github:flicaflow/julia_flake"; 
  };
  outputs = { self, nixpkgs, juliaFlake }:
    let pkgs = nixpkgs.legacyPackages.x86_64-linux; in
    {
      packages.x86_64-linux = rec {
        cilium = pkgs.callPackage ./pkgs/cilium.nix { };
        foliate = pkgs.libsForQt5.callPackage ./pkgs/foliate.nix { };
        julia = pkgs.callPackage ./pkgs/julia { };

        profiles = { };
      };
    };
}
