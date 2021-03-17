
{ config, pkgs, lib, modulesPath, ... }: {

  imports = [ "${modulesPath}/profiles/qemu-guest.nix" ];

  config = {

  networking = { hostName = "netcup"; };

    services.qemuGuest.enable = true;


    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
      autoResize = true;
    };

    boot.growPartition = true;
    boot.kernelParams = [ "console=ttyS0" ];
    boot.loader.grub.device = "/dev/vda";
    boot.loader.timeout = 0;

    environment.systemPackages = with pkgs; [
      git
      htop
      nixfmt
      wget
    ];


    mainUser = "nik";
    mainUserHome = "${config.users.extraUsers.${config.mainUser}.home}";
    nasIP = "192.168.5.10";

    programs.ssh.startAgent = false;
  };
}
