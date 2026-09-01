# proxies/traefik.nix - Traefik Cloud-Native Edge Router
{ config, pkgs, lib, vars, ... }:
let
  enableDocker = vars.containers ? docker && vars.containers.docker;
  acmeEmail = vars.acmeEmail or "admin@local.lan";
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

      # API / Dashboard (enabled for LAN/monitoring on :8080)
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

      # Automated Let's Encrypt / ACME SSL Certificate Resolver
      certificatesResolvers = {
        letsencrypt = {
          acme = {
            email = acmeEmail;
            storage = "/var/lib/traefik/acme.json";
            httpChallenge.entryPoint = "web";
          };
        };
      };

      log = {
        level = "INFO";
      };
    };

    # Dynamic file routing configuration (for non-Docker / local host services)
    # dynamicConfigOptions = {
    #   http = {
    #     routers = {
    #       my-app = {
    #         rule = "Host(`app.example.com`)";
    #         entryPoints = [ "websecure" ];
    #         service = "my-app-service";
    #         tls.certResolver = "letsencrypt";
    #       };
    #     };
    #     services = {
    #       my-app-service = {
    #         loadBalancer.servers = [
    #           { url = "http://127.0.0.1:3000"; }
    #         ];
    #       };
    #     };
    #   };
    # };
  };

  # Allow traefik system user to read Docker daemon socket
  users.users.traefik.extraGroups = lib.mkIf enableDocker [ "docker" ];

  # Open HTTP, HTTPS and Traefik dashboard
  networking.firewall.allowedTCPPorts = [ 80 443 8080 ];
}
