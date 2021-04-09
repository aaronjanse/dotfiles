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
      binutils
      cloc
      curl
      du-dust
      exa
      fd
      fzf
      git
      procs
      iptables
      tcpdump
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
        aria2
        autorandr
        binutils
        blueman
        cachix
        chromium
        cmake
        cmatrix
        cowsay
        cryfs
        cryptsetup
        dbeaver
        dgraph
        direnv
        discord
        docker
        docker-compose
        element-desktop
        elvish
        feh
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
        jetbrains.jdk
        julia
        kakoune
        khard
        kitty
        krita
        libreoffice
        libuuid.dev
        litecli
        lolcat
        matrix-synapse
        maven3
        mosh
        mullvad-vpn
        multimc
        nheko
        nim
        nix-direnv
        nixpkgs-fmt
        nodejs
        nodePackages.insect
        nodePackages.typescript
        okular
        pandoc
        pinentry-gtk2
        pkgconfig
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
        taskwarrior
        tldr
        tomb
        toot
        tor
        vdirsyncer
        vscode
        w3m
        wireguard
        xclip
        xwiimote
        yaml2json
        yarn
        youtube-dl
        zoom-us
      ]);
      extraOutputsToInstall = [ "man" "doc" ];
    };
}
