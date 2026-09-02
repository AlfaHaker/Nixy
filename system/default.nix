# system/default.nix - Base System Configuration Stack Entrypoint
{ config, pkgs, lib, ... }:
let
  vars = import ../variables.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ./users.nix
    ./ssh.nix
    ./services.nix
    ./systempackages.nix
  ] ++ (if (vars ? swap && vars.swap.enable) then [ ./swap.nix ] else [ ]);
}
