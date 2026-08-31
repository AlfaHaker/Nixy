# proxies/nginx.nix - High-Performance Nginx Reverse Proxy
{ config, pkgs, lib, vars, ... }:

{
  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    # Default server block
    virtualHosts."localhost" = {
      default = true;
      locations."/" = {
        return = "200 'Welcome to Nixy Server (Nginx Stack)\n'";
        extraConfig = ''
          default_type text/plain;
        '';
      };
    };
  };

  # Open standard web ports
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
