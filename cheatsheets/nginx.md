# Nginx Configuration Cheatsheet

This guide covers configuring **Nginx** in Nixy for both **Public Domains (via Let's Encrypt / ACME)** and **Local LAN / Private Networks (Plain HTTP, Custom Ports & Self-Signed Certs)**.

---

## 🌐 Part 1: Public SSL Configuration (Internet-Facing)

NixOS natively integrates `security.acme` with `services.nginx.virtualHosts` to automatically request and renew certificates.

### 1. Reverse Proxy with Automated Let's Encrypt SSL
Edit `proxies/nginx.nix`:
```nix
services.nginx.virtualHosts."app.yourdomain.com" = {
  enableACME = true;
  forceSSL = true;

  locations."/" = {
    proxyPass = "http://127.0.0.1:3000";
    proxyWebsockets = true; # Enable WebSocket headers (Upgrade & Connection)
    extraConfig = ''
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    '';
  };
};
```

### 2. Static File Serving with SSL
```nix
services.nginx.virtualHosts."docs.yourdomain.com" = {
  enableACME = true;
  forceSSL = true;
  root = "/var/www/docs";
};
```

---

## 🏠 Part 2: Local LAN, Private Networks & Internal Domains

### 1. Plain HTTP Virtual Host for `.lan` or `.local`
```nix
services.nginx.virtualHosts."dashboard.local.lan" = {
  # No SSL / HTTP Only on Port 80
  locations."/" = {
    proxyPass = "http://127.0.0.1:8080";
  };
};
```

### 2. Virtual Host Bound to Specific LAN IP / Custom Port
```nix
services.nginx.virtualHosts."192.168.1.100" = {
  listen = [
    { addr = "192.168.1.100"; port = 8080; }
  ];
  locations."/" = {
    proxyPass = "http://127.0.0.1:9000";
  };
};
```

### 3. Using Custom Self-Signed SSL Certificates
If you generated a private certificate (e.g. via `mkcert` or `openssl`):
```nix
services.nginx.virtualHosts."secure.local.lan" = {
  addSSL = true;
  sslCertificate = "/var/lib/ssl/local.crt";
  sslCertificateKey = "/var/lib/ssl/local.key";

  locations."/" = {
    proxyPass = "http://127.0.0.1:4000";
  };
};
```

### 4. Restricting Access to Local Subnets
```nix
services.nginx.virtualHosts."internal.local.lan" = {
  locations."/" = {
    proxyPass = "http://127.0.0.1:5000";
    extraConfig = ''
      allow 192.168.1.0/24;
      allow 10.0.0.0/8;
      allow 127.0.0.1;
      deny all;
    '';
  };
};
```
