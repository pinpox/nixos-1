{ config, pkgs, lib, modulesPath, ... }: {

  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  config = {

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };

    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.device = "/dev/vda";
    boot.loader.timeout = 0;

    mainUser = "nik";
    mainUserHome = "${config.users.extraUsers.${config.mainUser}.home}";
    nasIP = "192.168.5.10";

    programs.ssh.startAgent = false;
  };
}
