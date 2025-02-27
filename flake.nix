{
  description = "My NixOS infrastructure";

  inputs = {

    # Nix Packages collection
    # https://github.com/NixOS/nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.11";

    # Nix Packages collection
    # https://github.com/NixOS/nixpkgs/tree/nixos-unstable
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # Manage a user environment using Nix 
    # https://github.com/nix-community/home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-22.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Pure Nix flake utility functions
    # https://github.com/numtide/flake-utils
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    # lollypops deployment tool
    # https://github.com/pinpox/lollypops
    lollypops = {
      url = "github:pinpox/lollypops";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # A collection of NixOS modules covering hardware quirks.
    # https://github.com/NixOS/nixos-hardware
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };

    # Visual Studio Code Server support in NixOS
    # https://github.com/msteen/nixos-vscode-server
    vscode-server = {
      url = "github:msteen/nixos-vscode-server";
    };

    # Adblocking lists for Unbound DNS servers running on NixOS
    # https://github.com/MayNiklas/nixos-adblock-unbound
    adblock-unbound = {
      url = "github:MayNiklas/nixos-adblock-unbound";
      inputs = {
        adblockStevenBlack.follows = "adblockStevenBlack";
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # Adblocking lists for DNS servers
    # input here, so it will get updated by nix flake update
    adblockStevenBlack = {
      url = "github:StevenBlack/hosts";
      flake = false;
    };

    # # Prometheus exporter providing temperature metrics
    # # https://github.com/MayNiklas/dyson-exporter
    # dyson-exporter = {
    #   url = "github:MayNiklas/dyson-exporter";
    #   inputs = {
    #     flake-utils.follows = "flake-utils";
    #     nixpkgs.follows = "nixpkgs";
    #   };
    # };

    # A Shelly power metrics exporter written in golang. 
    # https://github.com/MayNiklas/shelly-exporter
    shelly-exporter = {
      url = "github:MayNiklas/shelly-exporter";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    # A valorant metrics exporter written in golang. 
    # https://github.com/MayNiklas/valorant-exporter
    valorant-exporter = {
      url = "github:MayNiklas/valorant-exporter";
      inputs = {
        flake-utils.follows = "flake-utils";
        nixpkgs.follows = "nixpkgs";
      };
    };

    whisper_api = {
      url = "github:MayNiklas/whisper_api";
    };

    cachix.url = "github:cachix/cachix/v1.2";

  };
  outputs = { self, ... }@inputs:
    with inputs;
    {

      nixConfig = {
        extra-substituters = [
          "https://mayniklas.cachix.org"
        ];
        extra-trusted-public-keys = [
          "mayniklas.cachix.org-1:gti3flcBaUNMoDN2nWCOPzCi2P68B5JbA/4jhUqHAFU="
        ];
      };

      # Expose overlay to flake outputs, to allow using it from other flakes.
      # Flake inputs are passed to the overlay so that the packages defined in
      # it can use the sources pinned in flake.lock
      overlays.default = final: prev: (import ./overlays inputs) final prev;

      overlays.mayniklas = final: prev: (import ./overlays/mayniklas.nix inputs) final prev;

      templates = import ./templates;

      # Output all modules in ./modules to flake. Modules should be in
      # individual subdirectories and contain a default.nix file
      nixosModules = builtins.listToAttrs
        (map
          (x: {
            name = x;
            value = import (./modules + "/${x}");
          })
          (builtins.attrNames (builtins.readDir ./modules)))

      //

      {
        home-manager = { config, pkgs, lib, ... }:
          let
            cfg = config.mayniklas.home-manager;
          in
          {
            imports = [ ./home-manager ];

            home-manager.users."${cfg.username}" = lib.mkIf cfg.enable {
              imports = [
                vscode-server.nixosModules.home
              ];

              # Visual Studio Code Server support
              services.vscode-server.enable = true;

            };
          };
      };

      # nix run .#homeConfigurations.nik@MacBook-Pro-14-2021.activationPackage
      # home-manager switch --flake .
      homeConfigurations."nik@MacBook-Pro-14-2021" =
        let
          system = "aarch64-darwin";
          pkgs = import nixpkgs-unstable {
            inherit system;
            config = { allowUnfree = true; };
            overlays = [ ];
          };
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            { }
            ./home-manager/profiles/mac.nix
          ];
          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
          extraSpecialArgs = { } // inputs;
        };

      # Each subdirectory in ./machines is a host. Add them all to
      # nixosConfiguratons. Host configurations need a file called
      # configuration.nix that will be read first
      nixosConfigurations = builtins.listToAttrs
        (map
          (x: {
            name = x;
            value = nixpkgs.lib.nixosSystem {

              # Make inputs and the flake itself accessible as module parameters.
              # Technically, adding the inputs is redundant as they can be also
              # accessed with flake-self.inputs.X, but adding them individually
              # allows to only pass what is needed to each module.
              specialArgs = { flake-self = self; } // inputs;

              system = "x86_64-linux";

              modules = [
                lollypops.nixosModules.lollypops
                (./machines + "/${x}/configuration.nix")
                { imports = builtins.attrValues self.nixosModules; }
              ];
            };
          })
          (builtins.attrNames (builtins.readDir ./machines)))

      // {

        hetzner-x86 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { flake-self = self; } // inputs;
          modules = [
            lollypops.nixosModules.lollypops
            ./images/hetzner-x86/configuration.nix
            { imports = builtins.attrValues self.nixosModules; }
          ];
        };

      };

      # nix build '.#netcup-x86-image'
      netcup-x86-image =
        let system = "x86_64-linux";
        in
        import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
          pkgs = nixpkgs.legacyPackages."${system}";
          lib = nixpkgs.lib;
          config = (nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [ ./images/netcup-x86/configuration.nix ];
          }).config;
          format = "qcow2";
          name = "base-image";
        };


      # nix build '.#linode-x86-image'
      linode-x86-image =
        let system = "x86_64-linux";
        in
        import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
          pkgs = nixpkgs.legacyPackages."${system}";
          lib = nixpkgs.lib;
          config = (nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [ ./images/linode-x86/configuration.nix ];
          }).config;
          format = "raw";
          name = "linode-image";
        };

      # nix build .#vmware-x86-image.config.system.build.vmwareImage
      vmware-x86-image =
        let system = "x86_64-linux";
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { flake-self = self; } // inputs;
          lib = nixpkgs.lib;
          modules = [
            ./images/vmware-x86/configuration.nix
            { imports = builtins.attrValues self.nixosModules; }
          ];
        };

      # nix build '.#usb-desktop-image'
      usb-desktop-image =
        let system = "x86_64-linux";
        in
        import "${nixpkgs}/nixos/lib/make-disk-image.nix" {
          pkgs = nixpkgs.legacyPackages."${system}";
          lib = nixpkgs.lib;
          config = (nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [ ./images/usb-desktop/configuration.nix ];
          }).config;
          partitionTableType = "efi";
          format = "raw";
          name = "usb-desktop-image";
        };

    } //

    # All packages in the ./packages subfolder are also added to the flake.
    # flake-utils is used for this part to make each package available for each
    # system. This works as all packages are compatible with all architectures
    (flake-utils.lib.eachSystem (flake-utils.lib.defaultSystems ++ [ "aarch64-darwin" ]))
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
            config = {
              allowUnsupportedSystem = true;
              allowUnfree = true;
            };
          };
        in
        rec {

          # Use nixpkgs-fmt for `nix fmt'
          formatter = pkgs.nixpkgs-fmt;

          # Custom packages added via the overlay are selectively exposed here, to
          # allow using them from other flakes that import this one.

          packages = flake-utils.lib.flattenTree {
            build-system = pkgs.build-system;
            drone-gen = pkgs.drone-gen;
            mtu-check = pkgs.mtu-check;
            s3uploader = pkgs.s3uploader;
            update-input = pkgs.update-input;
            vs-fix = pkgs.vs-fix;
          };

          # Allow custom packages to be run using `nix run`
          apps = {
            build-system = flake-utils.lib.mkApp { drv = packages.build-system; };
            drone-gen = flake-utils.lib.mkApp { drv = packages.drone-gen; };
            s3uploader = flake-utils.lib.mkApp { drv = packages.s3uploader; };
            update-input = flake-utils.lib.mkApp { drv = packages.update-input; };
            vs-fix = flake-utils.lib.mkApp { drv = packages.vs-fix; };

            # lollypops deployment tool
            # https://github.com/pinpox/lollypops
            #
            # nix run '.#lollypops' -- --list-all
            # nix run '.#lollypops' -- aida
            # nix run '.#lollypops' -- aida kora
            # nix run '.#lollypops' -- aida deke kora simmons snowflake the-bus -p
            default = self.apps.${pkgs.system}.lollypops;
            lollypops = lollypops.apps.${pkgs.system}.default {
              configFlake = self;
            };

          };
        });
}
