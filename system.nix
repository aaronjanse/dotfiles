{ config, lib, pkgs, options, ... }:
let
  cfg = {
    username = "ajanse";
    hostname = "ajanse-xps";
  };
in
{
  nixpkgs.config.allowUnfree = true;
  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-references
    '';
  };


  /* XPS 13 Hardware */

  boot.kernelParams = [ "mem_sleep_default=deep" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.requestEncryptionCredentials = true;
  hardware.enableRedistributableFirmware = true;
  powerManagement.powertop.enable = true;

  /* Boot */

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
    grub.enable = false;
  };

  boot.loader.grub.copyKernels = true;

  boot.kernelPackages =
    let
      linux_pkg =
        { stdenv, buildPackages, fetchurl, perl, buildLinux, modDirVersionArg ? null, ... } @ args:
          with stdenv.lib;
          buildLinux (
            args // rec {
              version = "5.3.16";
              modDirVersion =
                if (modDirVersionArg == null)
                then concatStringsSep "." (take 3 (splitVersion "${version}.0"))
                else modDirVersionArg;
              kernelPatches = [{
                name = "fix-display";
                patch = pkgs.fetchpatch {
                  url = "https://bugs.freedesktop.org/attachment.cgi?id=144765";
                  sha256 = "sha256-Fc6V5UwZsU6K3ZhToQdbQdyxCFWd6kOxU6ACZKyaVZo=";
                };
              }];
              src = fetchurl {
                url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
                sha256 = "19asdv08rzp33f0zxa2swsfnbhy4zwg06agj7sdnfy4wfkrfwx49";
              };
            } // (args.argsOverride or { })
          );
      linux = pkgs.callPackage linux_pkg { };
    in
    pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor linux);

  /* Maintenance */

  time.timeZone = "America/Los_Angeles";

  services.journald.extraConfig = "MaxRetentionSec=1week";
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;

  /* Security */

  security.sudo = {
    enable = true;
    wheelNeedsPassword = true;
  };

  services.gnome3.gnome-keyring.enable = true;

  users.mutableUsers = true;
  users.users.${cfg.username} = {
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
    ];
    createHome = true;
    home = "/home/${cfg.username}";
  };

  /* Shell */

  users.defaultUserShell = pkgs.zsh;
  environment.pathsToLink = [ "/share/zsh" ];
  environment.variables.GOPATH = "/home/${cfg.username}/.go";

  /* Networking */

  networking = {
    hostName = cfg.hostname;
    networkmanager.enable = true;
    firewall.enable = true;
    nameservers = pkgs.lib.mkForce [ "193.138.218.74" ]; # mullvad
    iproute2.enable = true;
  };
  boot.extraModulePackages = [ config.boot.kernelPackages.wireguard ];
  services.mullvad-vpn.enable = true;

  /* Sound */

  sound.enable = true;
  hardware.pulseaudio = {
    enable = true;
    daemon.config = { flat-volumes = "no"; };
  };

  /* Bluetooth */

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.dbus.packages = [ pkgs.blueman ];
  hardware.pulseaudio = {
    extraModules = [ pkgs.pulseaudio-modules-bt ];
    package = pkgs.pulseaudioFull;
  };

  /* Yubikey */

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization pkgs.libu2f-host ];

  home-manager.users."${cfg.username}".home.file.".gnupg/gpg-agent.conf".text = "pinentry-program ${pkgs.pinentry-gtk2}/bin/pinentry";

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
    windowManager.i3.enable = true;
    displayManager = {
      defaultSession = "none+i3";
      autoLogin = {
        enable = true;
        user = cfg.username;
      };
    };
  };

  systemd.user.services.gui-decor = {
    description = "status bar and wallpaper service";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    script = ''
      ${pkgs.feh}/bin/feh --bg-fill ${./assets/cal.png}
      ${pkgs.python36.withPackages (ps: with ps; [ psutil i3ipc ])}/bin/python3 -u ${./bin/i3.py} | ${pkgs.lemonbar-xft}/bin/lemonbar -f "Overpass Mono:pixelsize=30;0" -f "Font Awesome 5 Free:pixelsize=30;0" -f "Font Awesome 5 Free:style=Solid:pixelsize=30;0" -u 4 -g x60 -B "#181920"
    '';
    serviceConfig.Restart = "always";
  };

  programs.light.enable = true;

  programs.xss-lock = {
    enable = true;
    lockerCommand = "${pkgs.xsecurelock}/bin/xsecurelock";
  };

  /* HiDPI */

  console = {
    earlySetup = true;
    font = "sun12x22";
  };
  services.xserver.dpi = 227;
  services.xserver.displayManager.sessionCommands = ''
    ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
      Xft.dpi: 192
    EOF
    ${pkgs.xorg.xrandr}/bin/xrandr --output eDP-1 --scale 1.25x1.25
  '';
  environment.variables = {
    GDK_SCALE = "1.5";
    GDK_DPI_SCALE = "0.75";
    XCURSOR_SIZE = "64";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };

  /* Touchpad */

  services.xserver.libinput = {
    enable = true;
    tappingDragLock = false;
    naturalScrolling = true;
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
  networking.hosts = {
    "192.168.1.249" = [ "BRW707781875760.local" ];
    "172.31.98.1" = [ "aruba.odyssys.net" ];
  };

  /* Default Fonts */

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs;[
      corefonts
      inconsolata
      terminus_font
      # dejavu_fonts
      ubuntu_font_family
      source-code-pro
      source-sans-pro
      source-serif-pro
      # roboto-mono
      # roboto
      overpass
      libre-baskerville
      font-awesome
    ];
  };

  /* Virtualization */

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = false; # takes a long time to build
  };
  virtualisation.docker = {
    enable = true;
    storageDriver = "zfs";
  };

  system.stateVersion = "19.03";
}
