{ config, lib, pkgs, options, ... }:

let
  theme = import ./theme.nix;
  secrets = pkgs.callPackage
    (import "${fetchGit {
      url = "ssh://git@github.com/aaronjanse/secrets.git";
      rev = "5506a87f7d2604596d5b6f0f404d4fbbd68b971b";
  }}") { };
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
  boot.zfs.requestEncryptionCredentials = true;
  hardware.enableRedistributableFirmware = true;
  powerManagement.powertop.enable = true;

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

  # boot.kernelPackages =
  #   let
  #     linux_pkg =
  #       { stdenv, lib, buildPackages, fetchurl, perl, buildLinux, modDirVersionArg ? null, ... } @ args:
  #         with lib;
  #         buildLinux (
  #           args // rec {
  #             version = "5.3.16";
  #             modDirVersion =
  #               if (modDirVersionArg == null)
  #               then concatStringsSep "." (take 3 (splitVersion "${version}.0"))
  #               else modDirVersionArg;
  #             kernelPatches = [{
  #               name = "fix-display";
  #               patch = pkgs.fetchpatch {
  #                 url = "https://bugs.freedesktop.org/attachment.cgi?id=144765";
  #                 sha256 = "sha256-Fc6V5UwZsU6K3ZhToQdbQdyxCFWd6kOxU6ACZKyaVZo=";
  #               };
  #             }];
  #             src = fetchurl {
  #               url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
  #               sha256 = "19asdv08rzp33f0zxa2swsfnbhy4zwg06agj7sdnfy4wfkrfwx49";
  #             };
  #           } // (args.argsOverride or { })
  #         );
  #     linux = pkgs.callPackage linux_pkg { };
  #   in
  #   pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux);

  /* Maintenance */

  time.timeZone = "America/Los_Angeles";

  services.journald.extraConfig = "MaxRetentionSec=1week";
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;

  /* Security */

  services.gnome3.gnome-keyring.enable = true;

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
      "libvirtd"
      "kvm"
      "adbusers"
      "docker"
      "bluetooth"
    ];
    createHome = true;
    home = "/home/ajanse";
  };

  /* Shell */

  users.defaultUserShell = pkgs.julia;
  environment.pathsToLink = [ "/share/zsh" "/share/fish" ];
  environment.variables.MOZ_X11_EGL = "1";
  environment.variables.EDITOR = "${pkgs.kakoune}/bin/kak";

  /* Networking */

  networking = {
    hostName = "xps-ajanse";
    networkmanager.enable = true;
    nameservers = pkgs.lib.mkForce [ "193.138.218.74" ]; # mullvad
    iproute2.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 80 ];
      allowedUDPPorts = [ 51820 ];
      trustedInterfaces = [ "wg0" ];
    };
    hosts = {
      "192.168.1.249" = [ "BRW707781875760.local" ];
      "172.31.98.1" = [ "aruba.odyssys.net" ];
      "127.0.0.1" = [ "localhost.dev" "local.metaculus.com" ];
    };
  };

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

  /* Yubikey */

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization pkgs.libu2f-host ];

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
    useGlamor = true;
    windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      configFile = import ./i3-config.nix pkgs;
    };
    displayManager = {
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = "ajanse";
      };
    };
  };

  services.picom.enable = true;

  systemd.user.services.gui-decor = {
    description = "status bar and wallpaper service";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    path = with pkgs; [ feh lemonbar-xft ];
    script = ''
      feh --bg-fill ${pkgs.cal-wallpaper}
      lemonbar
    '';
  };

  systemd.user.services.dunst = {
    description = "notification daemon";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    script = "${pkgs.dunst}/bin/dunst";
  };

  programs.xss-lock = {
    enable = true;
    lockerCommand = "${pkgs.xsecurelock}/bin/xsecurelock";
  };

  programs.light.enable = true;

  /* HiDPI */

  services.gpm.enable = true;
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
