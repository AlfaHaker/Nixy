# network/firewall.nix - Direct Firewall Rules & Trusted Interfaces
{ config, pkgs, lib, vars, ... }:
let
  enableDocker = vars.containers ? docker && vars.containers.docker;
  enableIncus = vars.containers ? incus && vars.containers.incus;
in {
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowPing = true;

    # Open custom incoming TCP ports (Services like Caddy, Traefik, SSH open their own automatically)
    allowedTCPPorts = [
      # 8080 # Example: custom app port
    ];

    # Open custom incoming UDP ports
    allowedUDPPorts = [
      # 51820 # Example: Wireguard VPN
    ];

    # Trust local loopback and dynamically enabled container/VM bridge interfaces
    trustedInterfaces = [ "lo" ]
      ++ (if enableDocker then [ "docker0" ] else [ ])
      ++ (if enableIncus then [ "incusbr0" ] else [ ]);

    # Suppress noise in systemd journals from blocked connection attempts
    logRefusedConnections = false;
  };
}
