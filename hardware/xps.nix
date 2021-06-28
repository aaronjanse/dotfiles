{ config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  networking.hostId = "188c5100";

  fileSystems."/" = {
    device = "zzroot/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "zzroot/nix";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "zzroot/home";
    fsType = "zfs";
  };

  fileSystems."/safe" = {
    neededForBoot = true;
    device = "zzroot/persist";
    fsType = "zfs";
  };

  fileSystems."/mnt/code" = {
    device = "zzroot/code";
    fsType = "zfs";
  };

  fileSystems."/annex" = {
    neededForBoot = true;
    device = "zzroot/annex";
    fsType = "zfs";
  };

  fileSystems."/home/private" = {
    fsType = "tmpfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/1752-74D2";
    fsType = "vfat";
  };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 12;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

}
