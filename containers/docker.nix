# containers/docker.nix - Docker Engine & Tooling
{ config, pkgs, lib, vars, ... }:
let
  dockerDataRoot = if vars.containers ? dockerDataRoot then vars.containers.dockerDataRoot else "/var/lib/docker";
in {
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    autoPrune = {
      enable = false;
      dates = "weekly";
    };
    # Docker Daemon Settings (/etc/docker/daemon.json)
    daemon.settings = {
      # Custom storage directory for images, volumes, and container layers.
      # Useful for pointing Docker storage to dedicated NVMe/HDD storage mounts.
      data-root = dockerDataRoot;

      # Container Log Rotation Configuration:
      # By default, Docker has UNRESTRICTED log growth which can fill the root disk.
      # - json-file: Standard Docker log driver compatible with `docker logs`.
      # - max-size (20m): Restricts individual container log files to 20 MB before rotating.
      # - max-file (3): Keeps at most 3 rotated log files per container (.log, .log.1, .log.2).
      # Total maximum log footprint per container = ~60 MB (20 MB x 3).
      log-driver = "json-file";
      log-opts = {
        "max-size" = "20m";
        "max-file" = "3";
      };
    };
  };

  # Docker helper CLI packages
  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
    dive # Image layer explorer
  ];
}
