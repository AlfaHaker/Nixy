# tty/fish.nix - Fish Shell Configuration
{ config, pkgs, lib, vars, ... }:

{
  programs.fish = {
    enable = true;
    shellAliases = {
      ll = "ls -lah --color=auto";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
      ports = "ss -tulpn";
      sysrebuild = "sudo nixos-rebuild switch";
      sysboot = "sudo nixos-rebuild boot";
      sysdiff = "nvd diff /run/current-system result";
    };
    interactiveShellInit = ''
      set -g fish_greeting "" # Disable default fish greeting
    '';
  };
}
