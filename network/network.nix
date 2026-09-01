# network/network.nix - Direct Network Stack & DNS configuration
{ config, pkgs, lib, vars, ... }:

{
  networking = {
    # System hostname & domain
    hostName = vars.hostname;
    domain = "local.lan";

    # Global DHCP or Static Addressing
    useDHCP = lib.mkDefault true;

    # Global DNS nameservers
    nameservers = [
      "1.1.1.1" # Cloudflare primary
      "8.8.8.8" # Google primary
      "9.9.9.9" # Quad9 secure
    ];

    # Prefer NetworkManager for dynamic setup
    networkmanager.enable = lib.mkDefault true;

    # Enable IPv6
    enableIPv6 = true;

    # Static Interface Configuration (Uncomment and customize when not using DHCP)
    # interfaces = {
    #   # Public / WAN Interface (e.g. eth0, ens18, enp3s0)
    #   eth0 = {
    #     ipv4.addresses = [{
    #       address = "203.0.113.10";
    #       prefixLength = 24;
    #     }];
    #   };
    #
    #   # Private / Local LAN Interface (e.g. eth1, ens19, vlan10)
    #   eth1 = {
    #     ipv4.addresses = [{
    #       address = "192.168.1.100";
    #       prefixLength = 24;
    #     }];
    #   };
    # };

    # Default Gateway for Static Public Routing
    # defaultGateway = {
    #   address = "203.0.113.1";
    #   interface = "eth0";
    # };
  };

  # Kernel packet forwarding for container bridges (Docker & Incus)
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
