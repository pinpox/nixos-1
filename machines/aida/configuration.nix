{ self, ... }: {

  mayniklas = {
    plex = { enable = true; };
    hosts = { enable = true; };
    server = {
      enable = true;
      homeConfig = {
        imports = [
          ../../home-manager/home-server.nix
          { nixpkgs.overlays = [ self.overlay ]; }
        ];
      };
    };
    vmware-guest.enable = true;
  };

  networking.hostName = "aida";

  system.stateVersion = "20.09";

}