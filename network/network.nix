# network/network.nix - Direct Network Stack & DNS configuration
{ config, pkgs, lib, vars, ... }:

{
  networking = {
    # System hostname (can also be read from vars or set directly here)
    hostName = vars.hostname;
    domain = "local.lan";

    # Global DNS nameservers
    nameservers = [
      "1.1.1.1" # Cloudflare primary
      "8.8.8.8" # Google primary
      "9.9.9.9" # Quad9 secure
    ];

    # Prefer NetworkManager for flexible interface/bonding/VLAN setup
    networkmanager.enable = lib.mkDefault true;

    # Enable IPv6
    enableIPv6 = true;
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
