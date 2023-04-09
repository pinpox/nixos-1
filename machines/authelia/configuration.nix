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
  static-site = pkgs.writeTextFile {
    name = "index.html";
    text = ''
      <!DOCTYPE html>
      <html>
        <head> <meta charset="UTF-8"> </head>
        <body>
        <h1>Hello World!</h1>
        <p>Greetings, humans</p>
        </body>
      </html>
    '';
    executable = false;
    destination = "/html/index.html";
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
    virtualHosts = {
      "static-site.lounge.rocks" = {
        extraConfig = ''
          encode gzip
          root * ${static-site}/html
          file_server
        '';
      };
    };
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
