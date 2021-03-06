{ config, lib, pkgs, options, ... }:

let
  theme = import ./theme.nix;
  secrets = import "${fetchGit {
      url = "ssh://git@github.com/aaronjanse/secrets.git";
      rev = "16fe9eb16fb4e32d5b2b3e5d4d5cbc3ac8e0ae32";
  }}"
    { inherit pkgs; };
in
{
  /* Nix preferences */

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-references
      builders-use-substitutes = true
    '';
    distributedBuilds = true;
  };

  nix.trustedUsers = [ "ajanse" ];

  /* XPS 13 hardware */

  boot.kernelParams = [ "mem_sleep_default=deep" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = [ "zzroot" ];
  hardware.enableRedistributableFirmware = true;
  powerManagement.powertop.enable = true;

  # Disable sleep
  # # systemd.targets.sleep.enable = false;
  # # systemd.targets.suspend.enable = false;
  # # systemd.targets.hibernate.enable = false;
  # # systemd.targets.hybrid-sleep.enable = false;

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
    driSupport32Bit = true;
  };
  environment.systemPackages = with pkgs; [
    nixFlakes
    git
    vaapiIntel
    vaapi-intel-hybrid
    libva-full
    libva-utils
    intel-media-driver
    v4l-utils
    gnome3.adwaita-icon-theme
    vanilla-dmz
  ];

  # services.neo4j = {
  #   enable = true;
  #   bolt.tlsLevel = "DISABLED";
  #   https.enable = false;
  #   extraServerConfig = ''
  #     apoc.export.file.enabled=true
  #   '';
  # };

  services.postgresql = {
    enable = true;
    ensureUsers = [ ];
    initialScript = secrets.postgresqlInit;
  };

  /* Boot */

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
    grub.enable = false;
  };

  boot.loader.grub.copyKernels = true;

  # boot.kernelPatches = let hashes = [
  #   "sha256-ffrN0y5Us/VJ1v6JObfkSVD4PCm23wueI0JXjoRcOao="
  #   "sha256-mh9MgRtLp4+sXjM6GHkAkyyvp5DP3yTxl+d/kJ3+KJQ="
  #   "sha256-1Jy1uv9x1c06/auY1aHN0SuyOsbIF1IcaK8/PuGmX8Q="
  #   "sha256-QE3NfIg60RxV528AbpNAcxIdToplRNm5DgMNPn6AjHQ="
  #   "sha256-zyL1g2oNiTzYfS5qUOehduGfzFfi2WIVLCQMg+XGBwE="
  #   "sha256-f79tof0O5HBFwLbddR9FOqqLsqGsHqMZM45uYZNcoec="
  #   "sha256-JD0bi4sjsI9qRpHXxcPlGpiiwXMu2oPm/HJU8iQI1ag="
  #   "sha256-V+AGk7FGNiidd22ektlGCvSh3Wo2bRrUWp6qgGmsKPI="
  # ]; in builtins.genList (i: {
  #   name = "fuse_passthrough ${toString (i+1)}/8";
  #   patch = pkgs.fetchpatch {
  #     url = "https://lore.kernel.org/lkml/20210125153057.3623715-${toString (i+2)}-balsini@android.com/raw";
  #     sha256 = builtins.elemAt hashes i;
  #   };
  # }) 8;

  /* Maintenance */

  time.timeZone = "America/Los_Angeles";

  services.journald.extraConfig = "MaxRetentionSec=1week";
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;

  systemd = {
    timers.zbak-snap = {
      wantedBy = [ "timers.target" ];
      partOf = [ "zbak-snap.service" ];
      timerConfig.OnCalendar = "*:0/15";
    };
    services.zbak-snap = {
      serviceConfig.Type = "oneshot";
      path = [ pkgs.zbak ];
      script = ''
        zbak snap zzroot/code --keep 7d24h4f
      '';
    };

    # timers.zbak-send = {
    #   wantedBy = [ "timers.target" ];
    #   partOf = [ "zbak-send.service" ];
    #   timerConfig.OnCalendar = "*:10,40";
    # };
    # services.zbak-send = {
    #   serviceConfig.Type = "oneshot";
    #   path = [ pkgs.zbak ];
    #   script = ''
    #     [ $(cat /sys/class/power_supply/BAT0/status) = "Full" ] && \
    #       zbak send --name ssd500gb \
    #                 --from zzroot/code \
    #                 --to root@100.112.12.44:rpool/code \
    #                 --keep 6m4w7d
    #   '';
    # };
  };

  /* Security */

  services.openssh.enable = true;

  services.gnome.gnome-keyring.enable = true;

  programs.adb.enable = true;

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };
  users.mutableUsers = true;
  users.users.ajanse = {
    isNormalUser = true;
    uid = 1000;
    group = "users";
    extraGroups = [
      "wheel"
      "lp" # for bluetooth
      "video"
      "audio"
      "vboxusers"
      "adbusers"
      "libvirtd"
      "kvm"
      "adbusers"
      "docker"
      "bluetooth"
    ];
    createHome = true;
    home = "/home/ajanse";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILBA0RNuRdCTQgK15gzpqMBHH9XBbkvE2z7orygz67jv" # Phone
    ];
  };

  users.users.enclave = {
    isNormalUser = true;
    uid = 1001;
    group = "users";
    extraGroups = [ "wheel" ];
    createHome = true;
    home = "/home/enclave";
  };

  /* Shell */

  users.defaultUserShell = pkgs.fish;
  environment.pathsToLink = [ "/share/zsh" "/share/fish" ];
  environment.variables.MOZ_X11_EGL = "1";
  environment.variables.EDITOR = "${pkgs.kakoune}/bin/kak";
  environment.etc."fish/config.fish".text = ''
    set REPO_DIR $HOME/school/sp21-s367
    set SNAPS_DIR $HOME/school/snaps-sp21-s367
    set GOPATH $HOME/.go

    alias enter="sudo ip netns exec wguard su - enclave"
    alias ls=exa
  '';

  /* Networking */

  networking = {
    hostName = "xps-ajanse";
    networkmanager.enable = true;
    nameservers = pkgs.lib.mkForce [ "193.138.218.74" ]; # mullvad
    iproute2.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 ];
      allowedUDPPorts = [ 51820 41641 ];
      trustedInterfaces = [ "wg0" ];
    };
    hosts = {
      "192.168.1.249" = [ "BRW707781875760.local" ];
      "172.31.98.1" = [ "aruba.odyssys.net" ];
      "127.0.0.1" = [ "localhost.dev" "local.metaculus.com" ];
    };
  };

  services.tailscale.enable = true;

  services.rpcbind.enable = true;
  services.nfs.server.enable = true;

  networking.wireguard.enable = true;
  networking.wireguard.interfaces.wg0 = secrets.wireguard;

  /* Sound */

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    daemon.config = { flat-volumes = "no"; };
  };

  /* Bluetooth */

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  programs.dconf.enable = true;
  services.dbus.packages = [ pkgs.blueman pkgs.foliate ];
  hardware.pulseaudio = {
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };

  services.pcscd.enable = true;
  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libu2f-host
    pkgs.android-udev-rules
  ];

  # systemd.user.sockets.gpg-agent-ssh = {
  #   wantedBy = [ "sockets.target" ];
  #   listenStreams = [ "%t/gnupg/S.gpg-agent.ssh" ];
  #   socketConfig = {
  #     FileDescriptorName = "ssh";
  #     Service = "gpg-agent.service";
  #     SocketMode = "0600";
  #     DirectoryMode = "0700";
  #   };
  # };

  # environment.shellInit = ''
  #   export GPG_TTY="$(tty)"
  #   ${pkgs.gnupg}/bin/gpg-connect-agent /bye
  #   export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  # '';

  # services.yubikey-agent.enable = true;

  programs = {
    ssh.startAgent = false;
    gnupg.agent.enable = true;
    gnupg.agent.enableSSHSupport = true;
    gnupg.agent.pinentryFlavor = "gtk2";
  };

  /* User Interface */

  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    desktopManager.gnome.enable = true;
  };

  programs.light.enable = true;

  /* HiDPI */

  console = {
    earlySetup = true;
    font = "sun12x22";
    colors = theme.colors16;
  };
  services.xserver.dpi = 192;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
      Xcursor.theme: Vanilla-DMZ
      Xcursor.size: 32
    EOF
    ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --scale 1.25x1.25
  '';
  environment.variables = {
    GDK_SCALE = "1.5";
    GDK_DPI_SCALE = "0.75";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };

  /* Peripherials */

  services.xserver.xkbOptions = "compose:caps";
  services.xserver.libinput = {
    enable = true;
    touchpad = {
      tappingDragLock = false;
      naturalScrolling = true;
    };
  };
  systemd.user.services.xinput-config = {
    description = "configure xinput for xps";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    script = ''
      ${pkgs.xorg.xinput}/bin/xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Accel Speed" 0.55 || true
      ${pkgs.xorg.xinput}/bin/xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Drag Enabled" 0 || true
      ${pkgs.xorg.xinput}/bin/xinput set-prop "SysPS/2 Synaptics TouchPad" "libinput Disable While Typing Enabled" 0 || true
    '';
  };

  /* Printing */

  services.printing.enable = true;
  services.printing.drivers = [ pkgs.brlaser pkgs.mfcl2740dwlpr pkgs.mfcl2740dwcupswrapper ];
  services.avahi.enable = true;
  services.avahi.nssmdns = true;

  /* Default Fonts */

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs;[
      corefonts
      inconsolata
      terminus_font
      dejavu_fonts
      ubuntu_font_family
      source-code-pro
      source-sans-pro
      source-serif-pro
      roboto-mono
      roboto
      overpass
      libre-baskerville
      font-awesome
      julia-mono
    ];
  };

  /* Virtualization */

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # virtualisation.libvirtd.enable = true;
  # virtualisation.cri-o = {
  #   enable = true;
  #   storageDriver = "vfs";
  # };
  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableExtensionPack = false; # takes a long time to build
  # };
  # virtualisation.docker = {
  #   enable = true;
  #   storageDriver = "zfs";
  # };

  system.stateVersion = "19.03";
}
