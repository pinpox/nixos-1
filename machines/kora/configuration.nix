{ pkgs, config, ... }: {

  imports = [ ./cron.nix ];

  home-manager.users."${config.mayniklas.home-manager.username}" = {
    home.packages =
      with pkgs; [
        go
        gotools

        # https://github.com/ryantm/nixpkgs-update
        # nixpkgs-update.packages.${pkgs.system}.nixpkgs-update
      ];
  };

  mayniklas = {
    cloud.pve-x86.enable = true;
    docker = { enable = true; };
    hosts = { enable = true; };
    metrics = {
      node = {
        enable = true;
        flake = true;
      };
    };
    plex-version-bot = { enable = true; };
    librespeedtest = {
      enable = true;
      port = "8000";
    };
    kernel = { enable = true; };
    server = {
      enable = true;
      home-manager = true;
    };
  };

  mayniklas.services.owncast = {
    enable = false;
    port = 8989;
    openFirewall = true;
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking = {
    hostName = "kora";
    dhcpcd.enable = false;
    interfaces.enp6s18.ipv4.addresses = [{
      address = "192.168.5.21";
      prefixLength = 24;
    }];
    defaultGateway = "192.168.5.1";
    nameservers = [ "192.168.5.1" "1.1.1.1" ];
    firewall = { allowedTCPPorts = [ 9100 9115 ]; };
  };

  system.stateVersion = "20.09";

}
