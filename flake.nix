{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      theme = import ./theme.nix;
    in
    {
      packages.x86_64-linux = {
        alacritty = pkgs.callPackage ./pkgs/alacritty.nix { inherit theme; };
        cilium = pkgs.callPackage ./pkgs/cilium.nix { };
        foliate = pkgs.libsForQt5.callPackage ./pkgs/foliate.nix { };
        git = pkgs.callPackage ./pkgs/git.nix { };
        julia = pkgs.callPackage ./pkgs/julia { };
        mx-puppet-discord = pkgs.callPackage ./pkgs/mx-puppet-discord { };
        rofi = pkgs.callPackage ./pkgs/rofi.nix { inherit theme; };
        signal-desktop = pkgs.callPackage ./pkgs/signal-desktop.nix { inherit theme; };
        xsecurelock = pkgs.callPackage ./pkgs/xsecurelock.nix { };

        profiles = { };
      };
    };
}
