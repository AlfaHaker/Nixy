# containers/incus.nix - Incus Container & VM Manager
{ config, pkgs, lib, vars, ... }:

{
  virtualisation.incus = {
    enable = true;
    # UI package configuration (if available)
    ui.enable = false;
  };

  # Incus client tools and kernel network capabilities
  environment.systemPackages = with pkgs; [
    incus
  ];

  # Enable packet forwarding for Incus network bridges
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv6.conf.all.forwarding" = 1;
  };
}
