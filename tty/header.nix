# tty/header.nix - Fastfetch System Info MOTD Banner
{ config, pkgs, lib, vars, ... }:

{
  environment.systemPackages = [ pkgs.fastfetch ];

  # Trigger fastfetch when logging into interactive shells
  environment.interactiveShellInit = ''
    if [[ $- == *i* ]] && [ -z "$ZELLIJ" ] && [ -z "$TMUX" ]; then
      ${pkgs.fastfetch}/bin/fastfetch --logo nixos_small
    fi
  '';
}
