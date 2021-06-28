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
      coreutils
      curl
      du-dust
      exa
      fd
      fzf
      git
      iptables
      jq
      procs
      (python3.withPackages
        (ps:
          with ps; [
            autopep8
            black
            flake8
            ipykernel
            ipython
            ipywidgets
            jupyter
            matplotlib
            mypy
            numpy
            pep8
            pyls-mypy
            requests
            scipy
            setuptools
            virtualenv
          ]))
      ripgrep
      tcpdump
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
        _1password
        _1password-gui
        age
        alacritty
        aria2
        autorandr
        binutils
        blueman
        bubblewrap
        cachix
        chromium
        cmake
        cmatrix
        codeql
        coq
        cowsay
        cryfs
        cryptsetup
        dbeaver
        dgraph
        dig
        direnv
        discord
        docker
        docker-compose
        element-desktop
        elementary-planner
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
        gnome3.gnome-boxes
        gnome3.gnome-screenshot
        gnome3.gnome-todo
        gnome3.nautilus
        gnumake
        go
        gocryptfs
        gopls
        graphviz
        hexyl
        htop
        imagemagick
        inetutils
        inkscape
        inotify-tools
        ipfs
        ipfs-cluster
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
        mbuffer
        morph
        mosh
        mullvad-vpn
        multimc
        nheko
        nim
        nix-direnv
        nixops
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
        quaternion
        rakudo
        rclone
        redis
        restic
        rustup
        signal-desktop
        smartmontools
        spotify
        sqlite
        sqlitebrowser
        sshfs
        tailscale
        taskwarrior
        tldr
        tomb
        toot
        tor
        toybox
        ulauncher
        vdirsyncer
        vscode
        w3m
        weechat
        wireguard
        xclip
        xwiimote
        yaml2json
        yarn
        youtube-dl
        zbak
        zola
        zoom-us
      ]);
      extraOutputsToInstall = [ "man" "doc" ];
    };
}
