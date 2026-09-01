# network/network.nix - Direct Network Stack, IP Addressing & DNS configuration
{ config, pkgs, lib, vars, ... }:
let
  # --- Network Addressing Configuration ---
  useDHCP = true;           # Set to false to apply static IP addressing below

  # Public / WAN Interface (Set when static IP is assigned by ISP or VPS host)
  public = {
    enable = false;
    interface = "eth0";     # e.g., "eth0", "ens18", "enp3s0"
    ipv4 = "";              # e.g., "203.0.113.10"
    prefixLength = 24;
    gateway = "";           # e.g., "203.0.113.1"
  };

  # Private / Local LAN Interface (Optional secondary interface / VLAN)
  private = {
    enable = false;
    interface = "eth1";     # e.g., "eth1", "ens19", "vlan10"
    ipv4 = "192.168.1.100";
    prefixLength = 24;
  };
in
{
  networking = {
    # System hostname & domain
    hostName = vars.hostname;
    domain = "local.lan";

    # Global DHCP or Static Addressing
    useDHCP = lib.mkDefault useDHCP;

    # Global DNS nameservers
    nameservers = [
      "1.1.1.1" # Cloudflare primary
      "8.8.8.8" # Google primary
      "9.9.9.9" # Quad9 secure
    ];

    # NetworkManager (enabled by default when using DHCP)
    networkmanager.enable = lib.mkDefault useDHCP;

    # Enable IPv6
    enableIPv6 = true;

    # Static Interface Configuration (Public / WAN & Private / LAN)
    interfaces = lib.mkMerge [
      (lib.mkIf (!useDHCP && public.enable && public.ipv4 != "") {
        ${public.interface} = {
          ipv4.addresses = [
            {
              address = public.ipv4;
              prefixLength = public.prefixLength;
            }
          ];
        };
      })
      (lib.mkIf (private.enable && private.ipv4 != "") {
        ${private.interface} = {
          ipv4.addresses = [
            {
              address = private.ipv4;
              prefixLength = private.prefixLength;
            }
          ];
        };
      })
    ];

    # Default Gateway (for static public routing)
    defaultGateway = lib.mkIf (!useDHCP && public.enable && public.gateway != "") {
      address = public.gateway;
      interface = public.interface;
    };
  };

  # Kernel sysctl parameters for network throughput, packet forwarding & connection tracking
  boot.kernel.sysctl = {
    # IPv4/IPv6 Packet forwarding for container bridges (Docker & Incus)
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;

    # TCP Buffer & Connection Backlog Optimizations
    "net.core.somaxconn" = 4096;
    "net.ipv4.tcp_max_syn_backlog" = 4096;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_fastopen" = 3;
  };
}
