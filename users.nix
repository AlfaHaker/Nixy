# users.nix - User accounts and group permissions
{ config, pkgs, lib, vars, ... }:
let
  username = vars.username;

  # Determine groups dynamically based on enabled stacks
  containerGroups = (if (vars.containers ? docker && vars.containers.docker) then [ "docker" ] else [ ])
    ++ (if (vars.containers ? incus && vars.containers.incus) then [ "incus-admin" ] else [ ]);

  # Dynamically resolve shell package (handling bashInteractive for interactive Bash)
  shellPkg = if (vars.shell or "zsh") == "bash" then pkgs.bashInteractive else pkgs.${vars.shell or "zsh"};
in {
  # Set default system-wide user shell dynamically
  users.defaultUserShell = shellPkg;

  # Allow passwordless sudo for the wheel group
  security.sudo.wheelNeedsPassword = false;

  # Configure primary administrative user dynamically
  users.users.${username} = {
    isNormalUser = true;
    description = "Primary Server Administrator (${username})";
    extraGroups = [
      "wheel"
      "networkmanager"
      "systemd-journal"
    ] ++ containerGroups;
    shell = shellPkg;
    openssh.authorizedKeys.keys = [
      # Paste your public SSH keys here:
      # "your_public_key"
    ];
  };
}
