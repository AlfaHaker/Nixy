# Caddy Configuration Cheatsheet

This guide covers configuring **Caddy** in Nixy for both **Public Domains (with Automatic Let's Encrypt SSL)** and **Local LAN / Private Networks (Plain HTTP or Self-Signed Internal TLS)**.

---

## 🌐 Part 1: Public SSL Configuration (Production & Internet-Facing)

Caddy automatically handles Let's Encrypt / ZeroSSL certificate issuance, verification, and renewals out of the box when a public domain is configured.

### 1. Basic Reverse Proxy with Auto HTTPS
Edit `proxies/caddy.nix`:
```nix
services.caddy = {
  enable = true;
  extraConfig = ''
    # Public domain reverse proxy
    app.yourdomain.com {
      reverse_proxy 127.0.0.1:3000
    }

    # Proxy with WebSocket support (e.g. Nextcloud, Node.js, WebSockets)
    chat.yourdomain.com {
      reverse_proxy 127.0.0.1:8000
    }
  '';
};
```

### 2. Global ACME Email Registration
```nix
services.caddy.extraConfig = ''
  {
    email admin@yourdomain.com
  }

  api.yourdomain.com {
    reverse_proxy 127.0.0.1:4000
  }
'';
```

---

## 🏠 Part 2: Local LAN, Private Networks & Internal Domains

When running services inside a Homelab, Tailscale/NetBird mesh, or private LAN without a public IP:

### 1. Automatic Local HTTPS (`tls internal`)
Caddy generates its own local Root Certificate Authority (CA) and issues self-signed HTTPS certificates for `.lan`, `.local`, or internal domains:
```nix
services.caddy.extraConfig = ''
  # Local domain with internal trusted TLS
  dashboard.local.lan {
    tls internal
    reverse_proxy 127.0.0.1:9000
  }

  # Tailscale / NetBird private IP with internal TLS
  100.64.0.5:8443 {
    tls internal
    reverse_proxy 127.0.0.1:8080
  }
'';
```

### 2. Pure Plain HTTP (No SSL / Port 80)
If you only want unencrypted HTTP for local development or behind an internal VPN:
```nix
services.caddy.extraConfig = ''
  # Explicitly bind to port 80 or prefix with http://
  http://vault.local.lan {
    reverse_proxy 127.0.0.1:8200
  }

  # Direct IP:Port binding
  :8080 {
    reverse_proxy 127.0.0.1:3000
  }
'';
```

### 3. Restricting Access to Local Subnets
```nix
services.caddy.extraConfig = ''
  admin.local.lan {
    @blocked not remote_ip 192.168.1.0/24 10.0.0.0/8 127.0.0.1
    respond @blocked "Forbidden" 403

    reverse_proxy 127.0.0.1:9090
  }
'';
```
