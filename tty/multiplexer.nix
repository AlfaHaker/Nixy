# tty/multiplexer.nix - Terminal Multiplexers & Agent Runtimes (Zellij / Herdr)
{ config, pkgs, lib, vars, ... }:

let
  zellijEnabled = vars ? zellij && vars.zellij;
  herdrEnabled = vars ? herdr && vars.herdr;
in
{
  # Install enabled terminal multiplexers
  environment.systemPackages =
    (if zellijEnabled then [ pkgs.zellij ] else [ ])
    ++ (if herdrEnabled then [ pkgs.herdr ] else [ ]);

  # Provide default Zellij configuration layout if enabled
  environment.etc = lib.mkIf zellijEnabled {
    "zellij/config.kdl".text = ''
      theme "dracula"
      simplified_ui true
      pane_frames true
      auto_layout true
      copy_on_select true
    '';
  };
}
