# systempackages.nix - System-wide packages and utilities with explanations
{ config, pkgs, ... }:

{
  # Optional System-wide packages - Uncomment any packages you wish to install:
  environment.systemPackages = with pkgs; [
    # --- Core CLI & Text Editors ---
    # neovim          # Modern, extensible Vim-fork text editor for configuration editing
    # nano            # Simple, beginner-friendly command-line text editor
    # git             # Version control system for managing code repositories and dotfiles
    # curl            # Command-line tool for transferring data with URLs (HTTP, HTTPS, FTP)
    # wget            # Network utility to retrieve files from the web via HTTP/HTTPS/FTP
    # rsync           # Fast, versatile remote and local file-copying and synchronization tool
    # tree            # Recursive directory listing program that produces a depth-indented file tree
    # jq              # Lightweight and flexible command-line JSON processor and filter
    # ripgrep         # Ultra-fast line-oriented search tool (rg) that respects .gitignore
    # fd              # Fast, user-friendly alternative to find with colorized output
    # bat             # Modern cat replacement with syntax highlighting and Git integration
    # eza             # Modern, feature-rich replacement for ls with colors and icons
    # nvd             # Nix/NixOS package version diff tool (powers the sysdiff alias)
    # which           # Shows the full path of shell commands
    # file            # Utility to determine file type based on binary headers/magic numbers
    # unzip           # Extraction tool for ZIP archives
    # p7zip           # Command-line port of 7-Zip file archiver with high compression
    # tar             # Archiving utility to create, maintain, and extract tape/tar archives

    # --- System Monitoring & Resource Analysis ---
    # htop            # Interactive and colorful process viewer and system monitor
    # btop            # Modern, aesthetically pleasing terminal resource monitor (CPU, memory, disks, network)
    # iotop           # Top-like I/O monitor to identify processes performing heavy disk reads/writes
    # iftop           # Real-time console bandwidth monitor for listening on network interfaces
    # ncdu            # NCurses disk usage analyzer for finding large files and directories quickly
    # dust            # Intuitive graphical terminal representation of du (disk usage)
    # fastfetch       # Ultra-fast, customizable system information and logo display tool

    # --- Networking & Troubleshooting Diagnostics ---
    # tcpdump         # Powerful command-line packet analyzer and sniffer for network debugging
    # iperf3          # Tool for active measurements of the maximum achievable bandwidth on IP networks
    # nmap            # Network exploration, port scanner, and security audit utility
    # ethtool         # Query and control network driver and hardware settings (NIC speed, duplex)
    # socat           # Multipurpose relay tool for bidirectional data transfer between two streams
    # netcat-gnu      # Utility for reading from and writing to network connections using TCP or UDP
    # dnsutils        # DNS lookup utilities including dig, nslookup, and host
    # iproute2        # Modern Linux network management CLI suite (ip addr, ip route, ip link, ss)
    # traceroute      # Diagnostic tool for displaying the route/path and measuring transit delays
    # mtr             # Network diagnostic tool combining traceroute and ping into a real-time report

    # --- Storage & Disk Management ---
    # parted          # Partition manipulation program for creating, resizing, and deleting disk partitions
    # e2fsprogs       # Utilities for creating, checking, and maintaining ext2, ext3, and ext4 file systems
    # xfsprogs        # Utilities for managing and repairing XFS file systems
    # btrfs-progs     # Administration utilities for the Btrfs copy-on-write file system
    # smartmontools   # Control and monitor S.M.A.R.T. disk health and temperature attributes
    # lsb-release     # Linux Standard Base release reporting utility
  ];
}
