# swap.nix - Declarative swap file configuration
{ config, pkgs, lib, vars, ... }:

{
  # Configure swap file dynamically based on variables.nix
  swapDevices = [
    {
      device = vars.swap.path or "/var/lib/swapfile";
      size = vars.swap.size or 1024; # Size in MiB (e.g. 1024 = 1GB)
    }
  ];
}
