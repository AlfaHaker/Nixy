# tty/bash.nix - Bash Shell Configuration
{ config, pkgs, lib, vars, ... }:

{
  programs.bash = {
    completion.enable = true;
    enableLsColors = true;
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
      export HISTSIZE=100000
      export HISTFILESIZE=200000
      shopt -s histappend
      shopt -s checkwinsize
    '';
  };
}
