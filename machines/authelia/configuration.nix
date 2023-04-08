{ self, config, pkgs, ... }:

let
  caddy-with-plugins = pkgs.caddy.override {
    buildGoModule = args: pkgs.buildGoModule (args // {
      # vendorSha256 = "sha256-445MYvi487ls6g6i30UTTK2/n2wbILgJEuwNUQE//ZE";
      patches = [ ./caddy.patch ];
      vendorHash = "sha256-rgbHvCX3lf5oKSCmkUjdhFtITFUMysC5dn5fhvSyYco=";
      runVend = true;

    });
  };
in
{


  # server also runs keycloak for evaluation purposes
  mayniklas.keycloak.enable = true;

  mayniklas.nginx.enable = false;
  services.nginx.enable = false;


  environment.systemPackages = [ caddy-with-plugins ];

  services.caddy = {
    enable = true;
    package = caddy-with-plugins;
  };

  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        url = "https://github.com/pinpox.keys";
        hash = "sha256-V0ek+L0axLt8v1sdyPXHfZgkbOxqwE3Zw8vOT2aNDcE=";
      })
    ];
  };

  mayniklas = {
    cloud.hetzner-x86 = {
      enable = true;
      interface = "ens3";
      ipv6_address = "2a01:4f8:1c1c:80de::";
    };
    server = {
      enable = true;
      home-manager = true;
    };
  };

  networking = {
    hostName = "authelia";
    firewall = {
      allowedTCPPorts = [ 80 443 ];
    };
  };

  system.stateVersion = "22.05";

}
