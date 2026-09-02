# variables.nix - Nixy Central Control Panel
{
  # System Identity & Localization
  hostname = "nixy";
  username = "user";
  timezone = "Africa/Cairo";

  # Storage / State & Swap
  stateVersion = "26.05";
  swap = {
    enable = true;          # Enable declarative swapfile
    size = 1024;            # Size in MiB (e.g. 1024 = 1GB, 8192 = 8GB)
    path = "/var/lib/swapfile";
  };

  # Containerized Environment Stack
  containers = {
    docker = true;          # Enable Docker engine + compose + lazydocker
    dockerDataRoot = "/var/lib/docker";
    incus = false;          # Enable Incus containers & VMs + incus-admin group
  };

  # Reverse Proxy Stack
  # Options: "caddy" | "traefik" | "nginx" | "none"
  proxy = "none";

  # TTY / Shell & Terminal Stack
  # Options: "bash" | "zsh" | "fish"
  shell = "zsh";
  zellij = false;            # Enable Zellij terminal multiplexer
  herdr = true;             # Enable Herdr agent runtime & terminal manager
  header = true;            # Enable fastfetch MOTD banner on login
}
