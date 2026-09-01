# services.nix - Base system daemons and maintenance services
{ config, pkgs, lib, vars, ... }:

{
  # Intrusion prevention service for SSH
  services.fail2ban = {
    enable = true;
    maxretry = 5;
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
      "10.0.0.0/8"
      "172.16.0.0/12"
      "192.168.0.0/16"
    ];
  };

  # Guest virtualization agent (harmless if not on QEMU/KVM/Proxmox)
  services.qemuGuest.enable = true;

  # Accurate time synchronization
  services.timesyncd.enable = true;

  # Periodic system TRIM for SSDs / NVMe
  services.fstrim.enable = true;

  # Log management and journald retention
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=1month
  '';
}
