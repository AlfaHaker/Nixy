# proxies/caddy.nix - Caddy Reverse Proxy & Web Server
{ config, pkgs, lib, vars, ... }:
let
  acmeEmail = vars.acmeEmail or "admin@local.lan";
in {
  services.caddy = {
    enable = true;
    extraConfig = ''
      # Global Options
      {
        email ${acmeEmail}
        # auto_https off # Uncomment to disable automatic HTTPS when testing on local IP
      }

      # Default fallback handler
      :80 {
        respond "Welcome to Nixy Server (Caddy Stack)" 200
      }

      # Example Virtual Host with automatic Let's Encrypt SSL:
      # app.example.com {
      #   reverse_proxy 127.0.0.1:3000
      # }
    '';
  };

  # Open standard HTTP/HTTPS firewall ports for Caddy
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
