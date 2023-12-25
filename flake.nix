{
  description = "Aaron Janse's Nix things";

  inputs = {
    nixpkgsOrig.url = "github:nixos/nixpkgs/007126eef72271480cb7670e19e501a1ad2c1ff2";
    home-manager.url = "github:nix-community/home-manager/4cc1b77c3fc4f4b3bc61921dda72663eea962fa3";
  };

  outputs = { self, nixpkgsOrig, home-manager }: {
    nixosConfigurations.ajanse-xps = nixpkgsOrig.lib.nixosSystem {
      inherit (self.packages.x86_64-linux) pkgs;
      system = "x86_64-linux";
      modules = [
        ./system.nix
        ./system-hardware.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
        }
      ];
    };

    packages.x86_64-linux =
      let
        pkgs = import ./wrapped-pkgs.nix { inherit nixpkgsOrig; };
      in
      {
        inherit pkgs;
        barebones = pkgs.buildEnv {
          name = "ajanse-env-barebones";
          paths = with pkgs; [
            nixFlakes
            wget
            curl
            zip
            unzip
            vim
            git-wrapped
            ripgrep
          ];
          extraOutputsToInstall = [ "man" "doc" ];
        };
        minimal = pkgs.buildEnv {
          name = "ajanse-env-minimal";
          paths = with pkgs; [
            self.packages.x86_64-linux.barebones
            cachix
            nixops
            htop
            zsh
            fzf
            tldr
            cloc
            hexyl
            lsof
            bat
            tree
            pstree
            cryptsetup
            gitAndTools.gh
            wireguard
          ];
          extraOutputsToInstall = [ "man" "doc" ];
        };
        medium = pkgs.buildEnv {
          name = "ajanse-env-medium";
          paths = with pkgs; [
            self.packages.x86_64-linux.minimal
            nodePackages.insect
            nixpkgs-fmt
            imagemagick
            tomb
            w3m
          ];
          extraOutputsToInstall = [ "man" "doc" ];
        };
        heavy = pkgs.buildEnv {
          name = "ajanse-env-heavy";
          paths = with pkgs; [
            self.packages.x86_64-linux.medium
            python3
            docker
            docker-compose
            go
            gcc
            ffmpeg
            yarn
            gnumake
            sqlite
            lolcat
            fortune
            cowsay
            cmatrix
            nodejs
          ];
          extraOutputsToInstall = [ "man" "doc" ];
        };
        gui = pkgs.buildEnv {
          name = "ajanse-env-gui";
          paths = with pkgs; [
            self.packages.x86_64-linux.heavy
            firefox
            chromium
            gnome3.gnome-screenshot
            discord
            okular
            xclip
            gnome3.nautilus
            signal-desktop
            vscode
            zoom-us
            spotify
            blueman
            mullvad-vpn
            rofi
            alacritty
            flameshot
          ];
          extraOutputsToInstall = [ "man" "doc" ];
        };
      };
  };
}
