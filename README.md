# Nixy — Modular & Variable-Driven NixOS Server Configuration Stack

**Nixy** is an opinionated, production-ready, variable-driven NixOS server configuration designed specifically for Linux / Infrastructure Engineers and SysAdmins.

Instead of writing sprawling, interdependent Nix configurations, **Nixy** centralizes high-level environment toggles into `variables.nix`, while keeping network and security configurations clean and direct.

---

## 🚀 Key Features

- ⚙️ **Variable-Driven Architecture**: Toggle entire software stacks from `variables.nix`.
- 📦 **Container Stack**: Independent switches for **Docker** (with Compose & Lazydocker) and **Incus** (LXC & KVM virtualization).
- 🌐 **Reverse Proxy Stack**: Native NixOS services for **Caddy**, **Traefik**, and **Nginx** (or `none`).
- 🛡️ **Direct Network Stack**: Hardened firewall, bridge interface routing (`docker0`, `incusbr0`), DNS, and kernel sysctl optimizations managed directly in `network/`.
- 💻 **TTY & Shell Stack**: Choose between **Bash**, **Zsh** (with autosuggestions & syntax highlighting), or **Fish**, plus **Zellij** multiplexer and **Fastfetch** login headers.
- 🔒 **Dedicated Security Modules**: Independent `ssh.nix`, `users.nix`, `services.nix`, and an extensively annotated `systempackages.nix`.

---

## 📂 Directory Structure

```text
/etc/nixos/ (or your cloned Nixy path)
├── configuration.nix           # Main system coordinator
├── variables.nix               # Central control panel (Containers, Proxy, Shell, Hostname)
├── hardware-configuration.nix   # Auto-generated system hardware spec
├── users.nix                   # User accounts, dynamic groups, authorized keys
├── ssh.nix                     # Hardened OpenSSH daemon settings
├── services.nix                # Fail2ban, QEMU agent, timesyncd, log retention
├── systempackages.nix          # Diagnostic, sysadmin & networking CLI packages (with explanations)
├── containers/
│   ├── default.nix
│   ├── docker.nix              # Enabled when containers.docker = true
│   └── incus.nix               # Enabled when containers.incus = true
├── proxies/
│   ├── default.nix
│   ├── caddy.nix               # Enabled when proxy = "caddy"
│   ├── traefik.nix             # Enabled when proxy = "traefik"
│   └── nginx.nix               # Enabled when proxy = "nginx"
├── network/
│   ├── default.nix
│   ├── network.nix             # Hostname, DNS, sysctl kernel forwarding
│   └── firewall.nix            # Port management & container bridge routing
└── tty/
    ├── default.nix
    ├── bash.nix                # Configured when shell = "bash"
    ├── zsh.nix                 # Configured when shell = "zsh"
    ├── fish.nix                # Configured when shell = "fish"
    ├── zellij.nix              # Configured when zellij = true
    └── header.nix              # Fastfetch banner when header = true
```

---

## 🎛️ Quick Configuration (`variables.nix`)

Open `variables.nix` and set your desired environment:

```nix
{
  # 1. System Identity & User
  hostname = "nixy";
  username = "user";
  timezone = "Africa/Cairo";
  stateVersion = "26.05";

  # 2. Containers (Docker & Incus can coexist)
  containers = {
    docker = true;          # Docker engine + compose + lazydocker
    dockerDataRoot = "/var/lib/docker"; # Custom storage location
    incus = true;           # Incus LXC containers & KVM virtual machines
  };

  # 3. Reverse Proxy ("caddy" | "traefik" | "nginx" | "none")
  proxy = "caddy";

  # 4. Shell Stack ("zsh" | "bash" | "fish")
  shell = "zsh";
  zellij = true;            # Terminal multiplexer
  header = true;            # Fastfetch MOTD banner
}
```

---

## 📦 Container Stack: Docker & Incus Coexistence

Nixy allows **Docker** and **Incus** to run side-by-side without network isolation issues or storage conflicts:

1. **Docker Engine**: Designed for OCI microservices, Docker Compose stacks, and developer workflows.
   - **Storage**: Managed by default in `/var/lib/docker` (or customized via `dockerDataRoot`).
   - **Log Protection**: Docker log rotation settings can be enabled in [containers/docker.nix](file:///mnt/Storage1/Projects/OS/NixOs/Nixy/containers/docker.nix) to cap log growth at ~60 MB per container (20 MB x 3 files), preventing disk exhaustion.
2. **Incus Virtualization**: Designed for full Linux system containers (LXC) and complete virtual machines (KVM).
   - Managed via `incus` CLI and isolated storage pools.
3. **Seamless Networking**:
   - Kernel IP packet forwarding (`net.ipv4.ip_forward = 1` and `net.ipv6.conf.all.forwarding = 1`) is enabled in [network/network.nix](file:///mnt/Storage1/Projects/OS/NixOs/Nixy/network/network.nix).
   - Both `docker0` and `incusbr0` bridges are dynamically trusted in [network/firewall.nix](file:///mnt/Storage1/Projects/OS/NixOs/Nixy/network/firewall.nix), preventing Docker iptables rules from blocking Incus bridge traffic.

---

## 🛠️ Fresh Installation Guide

Follow these steps to deploy **Nixy** on a fresh baremetal server or VPS (Proxmox, Hetzner, Contabo, DigitalOcean, etc.).

### Step 1: Boot into the NixOS Minimal Installer

Boot the machine using the official [NixOS Minimal ISO](https://nixos.org/download.html).

### Step 2: Partition, Format, and Mount

*(Example for UEFI / GPT with Ext4)*:

```bash
# 1. Partition the disk (e.g. /dev/nvme0n1 or /dev/sda)
parted /dev/sda -- mklabel gpt
parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
parted /dev/sda -- set 1 esp on
parted /dev/sda -- mkpart primary ext4 512MiB 100%

# 2. Format partitions
mkfs.fat -F 32 -L boot /dev/sda1
mkfs.ext4 -L nixos /dev/sda2

# 3. Mount filesystems
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot
```

### Step 3: Generate Hardware Configuration

Run `nixos-generate-config` to generate your hardware configuration:

```bash
nixos-generate-config --root /mnt
```

### Step 4: Clone / Copy Nixy Configuration

Copy the Nixy stack to `/mnt/etc/nixos`:

```bash
# Copy Nixy files into /mnt/etc/nixos
cp -r /path/to/Nixy/* /mnt/etc/nixos/

# (The hardware-configuration.nix generated in Step 3 will be preserved)
```

### Step 5: Customize Variables & SSH Keys

1. Open `/mnt/etc/nixos/variables.nix` and set your `hostname`, `username`, and `timezone`.
2. Open `/mnt/etc/nixos/users.nix` and `/mnt/etc/nixos/ssh.nix` to add your public SSH keys for your primary user and root respectively.
3. Toggle your desired container engines (`docker`, `incus`), proxy (`caddy`, `traefik`, `nginx`, `none`), and default shell (`zsh`, `bash`, `fish`) in `variables.nix`.

### Step 6: Install & Reboot

```bash
# Set a root password if desired
nixos-install

# Reboot into your new Nixy server
reboot
```

---

## 🔄 Daily Administration & Workflow

Once installed, managing your server is clean and straightforward:

- **Rebuild and apply changes:**

  ```bash
  sysrebuild # alias for: sudo nixos-rebuild switch
  ```

- **Inspect active ports:**

  ```bash
  ports      # alias for: ss -tulpn
  ```

- **Manage Docker containers visually:**

  ```bash
  lazydocker
  ```

- **Manage Incus containers/VMs:**

  ```bash
  incus list
  incus launch images:ubuntu/24.04 my-ubuntu
  ```
