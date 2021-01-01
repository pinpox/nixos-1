{ config, pkgs, lib, ... }: {

  networking = {

    # Define your hostname
    hostName = "water-on-fire";

    # Define the DNS servers
    nameservers = [ "192.168.5.10" "192.168.5.1" "1.1.1.1" ];

    # Enables wireless support via wpa_supplicant.
    # networking.wireless.enable = true;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    # useDHCP = false;
    # interfaces.enp36s0.useDHCP = true;
    # interfaces.enp43s0.useDHCP = true;
    # interfaces.wlo1.useDHCP = true;

    # Enable networkmanager
    networkmanager.enable = true;

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Additional hosts to put in /etc/hosts
    extraHosts = ''
      # local
      192.168.5.15 vsphere.local
    '';
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
