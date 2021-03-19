# I use this file to manage which packages I have installed. To start using this file, I do:
# $ nix profile install github:aaronjanse/dotfiles#profiles.common
# Then, to update my local packages based on changes made here:
# $ nix porfile upgrade 0

{ pkgs }:

rec {
  # Installed everywhere
  common = pkgs.buildEnv {
    name = "ajanse-env-common";
    paths = with pkgs; [
      bat
      cloc
      curl
      fd
      fzf
      git
      jq
      (python3.withPackages
        (ps:
          with ps; [
            black
            flake8
            autopep8
            pep8
            pyls-mypy
            mypy
            setuptools
            virtualenv
          ]))
      ripgrep
      tree
      unzip
      vim
      wget
      zip
      zsh
    ];
    extraOutputsToInstall = [ "man" "doc" ];
  };

  # Installed on personal systems with a GUI
  gui = pkgs.buildEnv
    {
      name = "ajanse-env-common";
      # Include all package in `common` above
      paths = [ common ] ++ (with pkgs; [
        age
        alacritty
        anki
        audacity
        autorandr
        binutils
        blueman
        cachix
        calibre
        chromium
        cmake
        cmatrix
        cowsay
        cryfs
        cryptsetup
        dbeaver
        direnv
        discord
        docker
        docker-compose
        element-desktop
        elvish
        ffmpeg-full
        firefox-beta-bin
        fish
        flameshot
        foliate
        gcc
        git-annex
        git-annex-remote-rclone
        git-remote-gcrypt
        gitAndTools.gh
        gnome3.gnome-screenshot
        gnome3.nautilus
        gnumake
        go
        gopls
        hexyl
        htop
        imagemagick
        inkscape
        inotify-tools
        ipfs
        ipfs-cluster
        jetbrains.idea-community
        julia
        kak-lsp
        kakoune
        kakounePlugins.kak-fzf
        kitty
        krita
        kubectl
        kubernetes-helm
        libuuid.dev
        litecli
        lolcat
        lsof
        matrix-synapse
        maven3
        mosh
        mullvad-vpn
        multimc
        nheko
        nix-direnv
        nixpkgs-fmt
        nodejs
        nodePackages.insect
        nodePackages.typescript
        okular
        openjdk
        pandoc
        pinentry-gtk2
        pkgconfig
        powertop
        pstree
        python-language-server
        qt514.full
        quaternion
        rclone
        restic
        rustup
        signal-desktop
        spotify
        sqlite
        sqlitebrowser
        tailscale
        telnet
        tldr
        tomb
        toot
        vscode
        w3m
        wireguard
        xclip
        xwiimote
        yarn
        youtube-dl
        zoom-us
      ]);
      extraOutputsToInstall = [ "man" "doc" ];
    };
}
