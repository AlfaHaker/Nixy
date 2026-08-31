# tty/zellij.nix - Zellij Terminal Multiplexer Configuration
{ config, pkgs, lib, vars, ... }:

{
  environment.systemPackages = [ pkgs.zellij ];

  # Provide default server configuration layout
  environment.etc."zellij/config.kdl".text = ''
    theme "dracula"
    simplified_ui true
    pane_frames true
    auto_layout true
    copy_on_select true
  '';
}
