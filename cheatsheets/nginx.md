# Nginx Proxy Cheatsheet

This cheatsheet provides practical, copy-pasteable configuration patterns for **Nginx** across four core network scenarios.

---

## 🌐 Scenario A: Public Network (Internet-Facing)

### 1. HTTPS with Automatic SSL (Let's Encrypt / ACME)
NixOS natively provisions and renews SSL certificates using `security.acme`.

In `proxies/nginx.nix`:
```nix
services.nginx.virtualHosts."app.yourdomain.com" = {
  enableACME = true; # Request Let's Encrypt certificate
  forceSSL = true;   # Automatically redirect port 80 (HTTP) to port 443 (HTTPS)

  locations."/" = {
    proxyPass = "http://127.0.0.1:3000";
    proxyWebsockets = true; # Handle WebSocket headers (Upgrade & Connection)
    extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    '';
  };
};
```

### 2. Plain HTTP (No SSL on Public Port 80)
If you want to serve public web traffic without SSL:

```nix
services.nginx.virtualHosts."public-mirror.yourdomain.com" = {
  enableACME = false;
  forceSSL = false;

  locations."/" = {
    proxyPass = "http://127.0.0.1:8080";
  };
};
```

---

## 🏠 Scenario B: Local Network (Private LAN, VPN & Homelab)

### 1. HTTPS with Self-Signed SSL Certificate

#### Step 1: Generate Self-Signed Certificate (One-Liner)
Generate a wildcard self-signed certificate for your local network:
```bash
sudo mkdir -p /var/lib/ssl
sudo openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
  -keyout /var/lib/ssl/local.key \
  -out /var/lib/ssl/local.crt \
  -subj "/CN=*.local.lan"
```

#### Step 2: Configure Virtual Host in `proxies/nginx.nix`
```nix
services.nginx.virtualHosts."dashboard.local.lan" = {
  addSSL = true; # Enable SSL on port 443 without Let's Encrypt
  sslCertificate = "/var/lib/ssl/local.crt";
  sslCertificateKey = "/var/lib/ssl/local.key";

  locations."/" = {
    proxyPass = "http://127.0.0.1:9000";
    proxyWebsockets = true;
  };
};
```

---

### 2. Plain HTTP (Local LAN, Port Binding & Subnet Whitelist)
Unencrypted HTTP virtual host bound to local domains or specific LAN IP addresses.

```nix
# Virtual Host for internal .lan domain
services.nginx.virtualHosts."nas.local.lan" = {
  locations."/" = {
    proxyPass = "http://127.0.0.1:5000";
    extraConfig = ''
      # Restrict access to local private network subnets only
      allow 192.168.1.0/24;
      allow 10.0.0.0/8;
      allow 127.0.0.1;
      deny all;
    '';
  };
};

# Virtual Host bound to a specific LAN IP and custom port
services.nginx.virtualHosts."192.168.1.100" = {
  listen = [
    { addr = "192.168.1.100"; port = 8080; }
  ];
  locations."/" = {
    proxyPass = "http://127.0.0.1:8080";
  };
};
```
