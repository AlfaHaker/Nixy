# Caddy Proxy Cheatsheet

This cheatsheet provides practical, copy-pasteable configuration patterns for **Caddy** across four core network scenarios.

---

## 🌐 Scenario A: Public Network (Internet-Facing)

### 1. HTTPS with Automatic SSL (Let's Encrypt / ZeroSSL)
Caddy automatically handles public ACME verification, certificate renewals, and forces HTTPS redirects.

In `proxies/caddy.nix`:
```nix
services.caddy = {
  enable = true;
  extraConfig = ''
    # Public domain with auto-HTTPS & WebSocket reverse proxy
    app.yourdomain.com {
      reverse_proxy 127.0.0.1:3000
    }

    # Multiple subdomains on the same host
    api.yourdomain.com {
      reverse_proxy 127.0.0.1:4000
    }
  '';
};
```

### 2. Plain HTTP (No SSL on Port 80)
If you want to serve public traffic over unencrypted HTTP without SSL certificate generation:

```nix
services.caddy.extraConfig = ''
  # Prefix the domain with http:// to disable automatic HTTPS for this host
  http://public-mirror.yourdomain.com {
    reverse_proxy 127.0.0.1:8080
  }

  # Or globally disable auto-HTTPS in the global block:
  # {
  #   auto_https off
  # }
'';
```

---

## 🏠 Scenario B: Local Network (Private LAN, VPN & Homelab)

### 1. HTTPS with Auto-Generated Self-Signed SSL (`tls internal`)
Caddy contains an embedded Certificate Authority (CA) that **automatically generates, signs, and renews self-signed SSL certificates** on the fly for local domains (`.lan`, `.local`) or private LAN/VPN IPs without requiring manual OpenSSL commands:

```nix
services.caddy.extraConfig = ''
  # Auto-generated self-signed SSL for local .lan domain
  dashboard.local.lan {
    tls internal
    reverse_proxy 127.0.0.1:9000
  }

  # Auto-generated self-signed SSL for private IP / custom port
  192.168.1.100:8443 {
    tls internal
    reverse_proxy 127.0.0.1:8080
  }
'';
```

> **Tip:** Caddy saves its auto-generated local root certificate in `/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt`. You can import this root CA into your client browser or OS to make your self-signed certs trusted without security warnings.

### 2. Plain HTTP (Local LAN & IP Whitelist)
Unencrypted HTTP for internal network access:

```nix
services.caddy.extraConfig = ''
  # Local domain on plain HTTP (port 80)
  http://nas.local.lan {
    reverse_proxy 127.0.0.1:5000
  }

  # Custom LAN port binding with IP subnet restriction
  :8080 {
    @localnet remote_ip 192.168.1.0/24 10.0.0.0/8 127.0.0.1
    handle @localnet {
      reverse_proxy 127.0.0.1:8080
    }
    respond "Access Denied" 403
  }
'';
```
