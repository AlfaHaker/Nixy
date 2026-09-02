# containers/incus.nix - Incus Container & VM Manager
{ config, pkgs, lib, vars, ... }:

{
  virtualisation.incus = {
    enable = true;
    # UI package configuration (if available)
    ui.enable = false;
  };

}
