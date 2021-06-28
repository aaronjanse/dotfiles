{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-21.05";
    nixops.url = "github:nixos/nixops";
    zbak.url = "github:aaronjanse/zbak";
  };

  outputs = { self, nixpkgs, ... } @ args: {
    nixosConfigurations.xps-ajanse = nixpkgs.lib.nixosSystem {
      inherit (self.packages.x86_64-linux) pkgs;
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        ./hardware/xps.nix
      ];
    };

    packages = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.all (system:
      let
        pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
        theme = import ./theme.nix;
      in
      {
        pkgs = pkgs // removeAttrs self.packages.${system} [ "profiles" "pkgs" ];

        profiles = import ./profile.nix {
          inherit (self.packages.${system}) pkgs;
        };

        nixops = args.nixops.defaultPackage.${system};
        zbak = args.zbak.defaultPackage.${system};

        alacritty = pkgs.callPackage ./pkgs/alacritty.nix { inherit theme; };
        cal-wallpaper = pkgs.callPackage ./pkgs/cal-wallpaper { inherit theme; };
        cilium = pkgs.callPackage ./pkgs/cilium.nix { };
        direnv = pkgs.callPackage ./pkgs/direnv.nix { };
        dunst = pkgs.callPackage ./pkgs/dunst { };
        foliate = pkgs.libsForQt5.callPackage ./pkgs/foliate.nix { };
        git = pkgs.callPackage ./pkgs/git.nix { };
        julia = pkgs.callPackage ./pkgs/julia { };
        lemonbar-xft = pkgs.callPackage ./pkgs/lemonbar-xft { inherit theme; };
        mx-puppet-discord = pkgs.callPackage ./pkgs/mx-puppet-discord { };
        neo4j = pkgs.callPackage ./pkgs/neo4j.nix { };
        nix-zsh-completions = pkgs.callPackage ./pkgs/nix-zsh-completions.nix { };
        rofi = pkgs.callPackage ./pkgs/rofi.nix { inherit theme; };
        signal-desktop = pkgs.callPackage ./pkgs/signal-desktop.nix { inherit theme; };
        vscode = pkgs.callPackage ./pkgs/vscode.nix { };
        weylus = pkgs.callPackage ./pkgs/weylus.nix { };
        xsecurelock = pkgs.callPackage ./pkgs/xsecurelock.nix { };
        zsh = pkgs.callPackage ./pkgs/zsh {
          inherit theme;
          inherit (self.packages.${system}) nix-zsh-completions direnv;
        };
      }
    );
  };
}
