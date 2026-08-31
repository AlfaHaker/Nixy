# ssh.nix - OpenSSH daemon hardening and access rules
{ config, pkgs, lib, ... }:

{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    openFirewall = true;

    settings = {
      # Hardened authentication
      PermitRootLogin = "no"; # "no", "prohibit-password", or "yes"
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PubkeyAuthentication = true;

      # Session limits and security
      X11Forwarding = false;
      MaxAuthTries = 4;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
    };
  };

  # Root user SSH keys configuration
  users.users.root.openssh.authorizedKeys.keys = [
    # Paste your root public SSH keys here:
    # "your public key"
  ];
}
