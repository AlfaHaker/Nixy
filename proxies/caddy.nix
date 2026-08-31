# proxies/caddy.nix - Caddy Reverse Proxy & Web Server
{ config, pkgs, lib, vars, ... }:

{
  services.caddy = {
    enable = true;
    # Example base configuration; customize with your domains
    extraConfig = ''
      # Global Options
      {
        auto_https off # Set to on/default when deploying live domains with public ACME
      }

      # Default fallback handler
      :80 {
        respond "Welcome to Nixy Server (Caddy Stack)" 200
      }
    '';
  };

  # Open standard HTTP/HTTPS firewall ports for Caddy
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
