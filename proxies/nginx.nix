# proxies/nginx.nix - High-Performance Nginx Reverse Proxy
{ config, pkgs, lib, vars, ... }:
let
  acmeEmail = vars.acmeEmail or "admin@local.lan";
in {
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Default fallback server block
    virtualHosts."localhost" = {
      default = true;
      locations."/" = {
        return = "200 'Welcome to Nixy Server (Nginx Stack)\n'";
        extraConfig = ''
          default_type text/plain;
        '';
      };
    };

    # Example Virtual Host with automated Let's Encrypt SSL:
    # virtualHosts."app.example.com" = {
    #   enableACME = true;
    #   forceSSL = true;
    #   locations."/" = {
    #     proxyPass = "http://127.0.0.1:3000";
    #     proxyWebsockets = true;
    #   };
    # };
  };

  # Automatic Let's Encrypt (ACME) certificates configuration for Nginx
  security.acme = {
    acceptTerms = true;
    defaults.email = acmeEmail;
  };

  # Open standard web ports
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
