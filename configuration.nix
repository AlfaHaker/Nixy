# Nixy - Main System Configuration Entrypoint
{ config, pkgs, lib, ... }:
let
  vars = import ./variables.nix;
in {
  # Pass variables through NixOS args for modular consumption
  _module.args = { inherit vars; };

  imports = [ 
    ./hardware-configuration.nix
    ./users.nix
    ./ssh.nix
    ./services.nix
    ./systempackages.nix
    ./network
    ./containers
    ./proxies
    ./tty
  ] ++ (if (vars ? swap && vars.swap.enable) then [ ./swap.nix ] else [ ]);

  # Basic System Settings
  system.stateVersion = vars.stateVersion;
  time.timeZone = vars.timezone or "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Nix Package Manager & Flakes configuration
  nix.settings = {
    experimental-features = [
      "nix-command"
    ];
    auto-optimise-store = true;
    trusted-users = [
      "root"
      "@wheel"
    ];
  };

  # Automatic garbage collection for server health
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Enable bootloader (Systemd-boot with EFI by default)
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
  };
}
