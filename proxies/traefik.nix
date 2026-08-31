# proxies/traefik.nix - Traefik Cloud-Native Edge Router
{ config, pkgs, lib, vars, ... }:
let
  enableDocker = vars.containers ? docker && vars.containers.docker;
in {
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      # Entry points for HTTP, HTTPS, and Traefik Dashboard
      entryPoints = {
        web = {
          address = ":80";
        };
        websecure = {
          address = ":443";
        };
        traefik = {
          address = ":8080";
        };
      };

      # API / Dashboard (enabled in insecure mode for local LAN access on :8080)
      api = {
        dashboard = true;
        insecure = true;
      };

      # Automatic Docker container discovery provider
      providers = {
        docker = lib.mkIf enableDocker {
          endpoint = "unix:///var/run/docker.sock";
          exposedByDefault = false;
        };
      };

      log = {
        level = "INFO";
      };
    };
  };

  # Allow traefik system user to read Docker daemon socket
  users.users.traefik.extraGroups = lib.mkIf enableDocker [ "docker" ];

  # Open HTTP, HTTPS and Traefik dashboard
  networking.firewall.allowedTCPPorts = [ 80 443 8080 ];
}
