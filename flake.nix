{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: {
    # This defines my laptop's operating system. Here, I configure:
    # - hardware-specific settings (e.g. wifi, filesystem, gpu)
    # - workflow-specific settings (e.g. keybindings, window manager)
    nixosConfigurations.xps-ajanse = let pkgs = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    }; in
      nixpkgs.lib.nixosSystem {
        inherit (self.packages.x86_64-linux) pkgs;
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
          ./hardware/xps.nix
        ];
      };
    # We then generate `packages` and `apps` for each platform:
  } // flake-utils.lib.eachDefaultSystem (system:
    let
      theme = import ./theme.nix;
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    rec {
      # This defines new packages along with packages I've modified. I use
      # wrapProgram to telling packages to look for dotfiles in /nix/store.
      packages = {
        # Combine nixpkgs with the packages below
        pkgs = pkgs // removeAttrs self.packages.${system} [ "profiles" "pkgs" ];

        profiles = import ./profile.nix {
          inherit (self.packages.${system}) pkgs;
        };

        alacritty = pkgs.callPackage ./pkgs/alacritty.nix { inherit theme; };
        cal-wallpaper = pkgs.callPackage ./pkgs/cal-wallpaper { inherit theme; };
        cilium = pkgs.callPackage ./pkgs/cilium.nix { };
        direnv = pkgs.callPackage ./pkgs/direnv.nix { };
        dunst = pkgs.callPackage ./pkgs/dunst { };
        foliate = pkgs.libsForQt5.callPackage ./pkgs/foliate.nix { };
        git = pkgs.callPackage ./pkgs/git.nix { };
        julia = pkgs.callPackage ./pkgs/julia { };
        lemonbar-xft = pkgs.callPackage ./pkgs/lemonbar-xft { };
        neo4j = pkgs.callPackage ./pkgs/neo4j.nix { };
        mx-puppet-discord = pkgs.callPackage ./pkgs/mx-puppet-discord { };
        nix-zsh-completions = pkgs.callPackage ./pkgs/nix-zsh-completions.nix { };
        rofi = pkgs.callPackage ./pkgs/rofi.nix { inherit theme; };
        signal-desktop = pkgs.callPackage ./pkgs/signal-desktop.nix { inherit theme; };
        vscode = pkgs.callPackage ./pkgs/vscode.nix { };
        xsecurelock = pkgs.callPackage ./pkgs/xsecurelock.nix { };
        zsh = pkgs.callPackage ./pkgs/zsh {
          inherit theme;
          inherit (self.packages.${system}) nix-zsh-completions direnv;
        };
      };

      apps = {
        julia = { type = "app"; program = "${self.packages.${system}.julia}/bin/julia"; };
        julish = { type = "app"; program = "${self.packages.${system}.julia}/bin/julish"; };
      };
    });
}
