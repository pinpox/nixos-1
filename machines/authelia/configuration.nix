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

    globalConfig = ''
        order authenticate before respond
        order authorize before basicauth

        security {
                oauth identity provider generic {
                    realm generic
                    driver generic
                    client_id {env.GENERIC_CLIENT_ID}
                    client_secret {env.GENERIC_CLIENT_SECRET}
                    scopes openid email profile
                    base_auth_url https://git.0cx.de
                    metadata_url https://git.0cx.de/.well-known/openid-configuration
                }

                authentication portal myportal {
                    crypto default token lifetime 3600
                    crypto key sign-verify {env.JWT_SHARED_KEY}
                    enable identity provider generic
                    cookie domain lounge.rocks
                    ui {
                        links {
                            "My Identity" "/whoami" icon "las la-user"
                        }
                    }

                    transform user {
                        match realm generic
                        action add role authp/user
                        ui link "File Server" https://static-site.lounge.rocks/ icon "las la-star"
                    }

                    transform user {
                        match realm generic
                        match email greenpau@contoso.com
                        action add role authp/admin
                    }
                }

                authorization policy mypolicy {
                    set auth url https://auth.lounge.rocks/oauth2/generic
                    crypto key verify {env.JWT_SHARED_KEY}
                    allow roles authp/admin authp/user
                    validate bearer header
                    inject headers with claims
                }
            }
    '';

    virtualHosts = {

      "auth.lounge.rocks" = {
        extraConfig = ''
          authenticate with myportal
        '';
      };

      "static-site.lounge.rocks" = {
        extraConfig = ''
          authorize with mypolicy
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
