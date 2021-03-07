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
      python3
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
  gui = pkgs.buildEnv {
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
      discord
      docker
      docker-compose
      element-desktop
      ffmpeg-full
      firefox-beta-bin
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
      hexyl
      htop
      imagemagick
      inkscape
      inotify-tools
      ipfs
      ipfs-cluster
      jetbrains.idea-community
      julia
      kakoune
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
      qt514.full
      quaternion
      rclone
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