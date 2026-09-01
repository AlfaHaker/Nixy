# Traefik Proxy Cheatsheet

This cheatsheet provides practical, copy-pasteable configuration patterns for **Traefik** across four core network scenarios.

---

## 🌐 Scenario A: Public Network (Internet-Facing)

### 1. HTTPS with Automatic SSL (Let's Encrypt / ACME)

#### Method 1: Docker Container Labels (Recommended for Docker)
Add to your `docker-compose.yml`:
```yaml
services:
  web-app:
    image: my-app:latest
    container_name: web-app
    labels:
      - "traefik.enable=true"
      # Match public domain name
      - "traefik.http.routers.webapp.rule=Host(`app.yourdomain.com`)"
      # Route through HTTPS entrypoint
      - "traefik.http.routers.webapp.entrypoints=websecure"
      # Request Let's Encrypt SSL certificate
      - "traefik.http.routers.webapp.tls.certresolver=letsencrypt"
      # Target backend port inside the container
      - "traefik.http.services.webapp.loadbalancer.server.port=80"
```

#### Method 2: Declarative Host Router (In `proxies/traefik.nix` for Incus/Host Apps)
```nix
services.traefik.dynamicConfigOptions = {
  http = {
    routers = {
      public-service = {
        rule = "Host(`service.yourdomain.com`)";
        entryPoints = [ "websecure" ];
        service = "public-service-backend";
        tls.certResolver = "letsencrypt";
      };
    };

    services = {
      public-service-backend = {
        loadBalancer.servers = [
          { url = "http://127.0.0.1:3000"; }
        ];
      };
    };
  };
};
```

---

### 2. Plain HTTP (No SSL on Public Port 80)

#### Docker Compose Labels:
```yaml
services:
  public-http-app:
    image: nginx:alpine
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.plainapp.rule=Host(`public-mirror.yourdomain.com`)"
      # Bind only to the HTTP entrypoint (no TLS)
      - "traefik.http.routers.plainapp.entrypoints=web"
      - "traefik.http.services.plainapp.loadbalancer.server.port=80"
```

#### Declarative Router in `proxies/traefik.nix`:
```nix
services.traefik.dynamicConfigOptions.http.routers.plain-http = {
  rule = "Host(`public-mirror.yourdomain.com`)";
  entryPoints = [ "web" ]; # Plain HTTP entrypoint
  service = "plain-service-backend";
};
```

---

## 🏠 Scenario B: Local Network (Private LAN, VPN & Homelab)

### 1. HTTPS with Self-Signed / Custom SSL Certificate

#### Configure Custom Certificate in `proxies/traefik.nix`:
```nix
services.traefik.dynamicConfigOptions = {
  # Register local custom or self-signed certificates
  tls.certificates = [
    {
      certFile = "/var/lib/ssl/local.crt";
      keyFile = "/var/lib/ssl/local.key";
    }
  ];

  http.routers.secure-local = {
    rule = "Host(`dashboard.local.lan`)";
    entryPoints = [ "websecure" ];
    service = "local-backend";
    tls = { }; # Uses local certificate store above
  };

  http.services.local-backend.loadBalancer.servers = [
    { url = "http://127.0.0.1:9090"; }
  ];
};
```

#### Docker Compose Label with Local TLS:
```yaml
services:
  local-secure-container:
    image: my-app:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.localsecure.rule=Host(`secure.local.lan`)"
      - "traefik.http.routers.localsecure.entrypoints=websecure"
      - "traefik.http.routers.localsecure.tls=true"
      - "traefik.http.services.localsecure.loadbalancer.server.port=8080"
```

---

### 2. Plain HTTP (Local LAN & IP Whitelist)

#### Docker Compose Labels for Local `.lan` Service:
```yaml
services:
  local-nas:
    image: filebrowser/filebrowser
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.nas.rule=Host(`nas.local.lan`)"
      - "traefik.http.routers.nas.entrypoints=web"
      # Optional: Restrict access only to local subnet IPs
      - "traefik.http.middlewares.lan-only.ipwhitelist.sourcerange=192.168.1.0/24, 10.0.0.0/8, 127.0.0.1"
      - "traefik.http.routers.nas.middlewares=lan-only"
      - "traefik.http.services.nas.loadbalancer.server.port=80"
```

#### Declarative Router in `proxies/traefik.nix`:
```nix
services.traefik.dynamicConfigOptions.http = {
  routers.local-dashboard = {
    rule = "Host(`nas.local.lan`)";
    entryPoints = [ "web" ];
    service = "nas-backend";
  };
  services.nas-backend.loadBalancer.servers = [
    { url = "http://192.168.1.50:8080"; }
  ];
};
```
