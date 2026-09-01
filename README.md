# Nixy — Modular & Variable-Driven NixOS Server Configuration Stack

**Nixy** is an opinionated, production-ready, variable-driven NixOS server configuration designed specifically for Linux / Infrastructure Engineers and SysAdmins.

Instead of writing sprawling, interdependent Nix configurations, **Nixy** centralizes high-level environment toggles into `variables.nix`, while keeping network and security configurations clean and direct.

---

## 🚀 Key Features

- ⚙️ **Variable-Driven Architecture**: Toggle entire software stacks from `variables.nix`.
- 📦 **Container Stack**: Independent switches for **Docker** (with Compose & Lazydocker) and **Incus** (LXC & KVM virtualization).
- 🌐 **Reverse Proxy Stack**: Native NixOS services for **Caddy**, **Traefik**, and **Nginx** (or `none`).
- 🛡️ **Direct Network Stack**: Hardened firewall, bridge interface routing (`docker0`, `incusbr0`), DNS, and kernel sysctl optimizations managed directly in `network/`.
- 💻 **TTY & Shell Stack**: Choose between **Bash**, **Zsh** (with autosuggestions & syntax highlighting), or **Fish**, plus **Zellij** multiplexer, **Herdr** agent runtime, and **Fastfetch** login headers.
- 🔒 **Dedicated Security Modules**: Independent `ssh.nix`, `users.nix`, `services.nix`, and an extensively annotated `systempackages.nix`.

---

## 📂 Directory Structure

```text
/etc/nixos/ (or your cloned Nixy path)
├── configuration.nix           # Main system coordinator
├── variables.nix               # Central control panel (Containers, Proxy, Shell, Hostname)
├── hardware-configuration.nix   # Auto-generated system hardware spec
├── swap.nix                    # Declarative swapfile management
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
    ├── multiplexer.nix         # Configured when zellij or herdr = true
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

  # 2. Swap Configuration
  swap = {
    enable = true;          # Declarative swapfile
    size = 4096;            # Size in MiB (4096 = 4GB)
    path = "/var/lib/swapfile";
  };

  # 3. Containers (Docker & Incus can coexist)
  containers = {
    docker = true;          # Docker engine + compose + lazydocker
    dockerDataRoot = "/var/lib/docker"; # Custom storage location
    incus = true;           # Incus LXC containers & KVM virtual machines
  };

  # 4. Reverse Proxy ("caddy" | "traefik" | "nginx" | "none")
  proxy = "caddy";

  # 5. Shell Stack ("zsh" | "bash" | "fish")
  shell = "zsh";
  zellij = true;            # Terminal multiplexer
  herdr = true;             # Herdr agent runtime & workspace manager
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

## 🛠️ Installation & Deployment

<details>
<summary><b>Scenario A: Fresh Installation from Live ISO (Baremetal / VPS)</b></summary>

<br>

Follow these steps when installing NixOS and Nixy from the official [NixOS Minimal ISO](https://nixos.org/download.html).

#### Step 1: Partition, Format, and Mount

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

#### Step 2: Clone Nixy Configuration

```bash
# Clone Nixy repository directly into /mnt/etc/nixos
git clone https://github.com/AlfaHaker/Nixy.git /mnt/etc/nixos
```

#### Step 3: Generate Hardware Configuration

```bash
# Generate hardware configuration inside /mnt/etc/nixos
nixos-generate-config --root /mnt
```

#### Step 4: Customize Variables & SSH Keys

1. Open `/mnt/etc/nixos/variables.nix` and configure your `hostname`, `username`, `timezone`, and `swap` settings.
2. Open `/mnt/etc/nixos/users.nix` and `/mnt/etc/nixos/ssh.nix` to insert your public SSH keys.
3. Toggle container engines (`docker`, `incus`), proxy (`caddy`, `traefik`, `nginx`, `none`), and shell preference.

#### Step 5: Install & Reboot

```bash
nixos-install
reboot
```

</details>

<details>
<summary><b>Scenario B: Existing / Freshly Installed NixOS System</b></summary>

<br>

If you already have a running NixOS installation (e.g., a VPS cloud image or a fresh minimal install) and want to apply Nixy:

#### Step 1: Backup Existing Configuration

```bash
sudo cp -r /etc/nixos /etc/nixos.bak
```

#### Step 2: Clone Nixy & Preserve Hardware Configuration

```bash
# Move hardware-configuration.nix temporarily
sudo mv /etc/nixos/hardware-configuration.nix /tmp/hardware-configuration.nix
sudo rm -rf /etc/nixos

# Clone Nixy into /etc/nixos
sudo git clone https://github.com/AlfaHaker/Nixy.git /etc/nixos

# Restore your hardware configuration
sudo mv /tmp/hardware-configuration.nix /etc/nixos/hardware-configuration.nix
```

#### Step 3: Customize Variables & User

1. Open `/etc/nixos/variables.nix` and set your `hostname`, `username`, `timezone`, `swap`, and feature toggles.
2. Open `/etc/nixos/users.nix` and `/etc/nixos/ssh.nix` to verify your user and SSH keys.

#### Step 4: Build & Switch

```bash
# Test build first (optional)
sudo nixos-rebuild test

# Apply and switch to Nixy
sudo nixos-rebuild switch
```

</details>

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
