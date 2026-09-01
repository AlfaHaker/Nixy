# Traefik Configuration Cheatsheet

This guide covers configuring **Traefik** in Nixy for both **Public Domains (via Docker Labels & ACME Let's Encrypt)** and **Local LAN / Private Networks (Plain HTTP & Internal Routing)**.

---

## 🌐 Part 1: Public SSL Configuration (Internet-Facing)

### 1. Docker Container Discovery via Labels (Recommended)
Add labels to your container in `docker-compose.yml`:
```yaml
services:
  web-app:
    image: my-app:latest
    container_name: web-app
    restart: unless-stopped
    labels:
      - "traefik.enable=true"
      # Match public domain name
      - "traefik.http.routers.webapp.rule=Host(`app.yourdomain.com`)"
      # Route through HTTPS (port 443)
      - "traefik.http.routers.webapp.entrypoints=websecure"
      # Request automatic Let's Encrypt SSL certificate
      - "traefik.http.routers.webapp.tls.certresolver=letsencrypt"
      # Point to internal container port
      - "traefik.http.services.webapp.loadbalancer.server.port=80"
```

### 2. Declarative Host Routing in `proxies/traefik.nix` (For Local / Incus / Host Services)
```nix
services.traefik.dynamicConfigOptions = {
  http = {
    routers = {
      my-host-app = {
        rule = "Host(`service.yourdomain.com`)";
        entryPoints = [ "websecure" ];
        service = "my-host-app-service";
        tls.certResolver = "letsencrypt";
      };
    };

    services = {
      my-host-app-service = {
        loadBalancer.servers = [
          { url = "http://127.0.0.1:3000"; }
        ];
      };
    };
  };
};
```

---

## 🏠 Part 2: Local LAN, Private Networks & Internal Domains

### 1. Docker Container without SSL (Plain HTTP on Port 80)
```yaml
services:
  local-service:
    image: nginx:alpine
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.localsvc.rule=Host(`service.local.lan`)"
      - "traefik.http.routers.localsvc.entrypoints=web"
      - "traefik.http.services.localsvc.loadbalancer.server.port=80"
```

### 2. Declarative Plain HTTP Route in `proxies/traefik.nix`
```nix
services.traefik.dynamicConfigOptions = {
  http = {
    routers = {
      nas-ui = {
        rule = "Host(`nas.local.lan`)";
        entryPoints = [ "web" ]; # Plain HTTP
        service = "nas-service";
      };
    };

    services = {
      nas-service = {
        loadBalancer.servers = [
          { url = "http://192.168.1.50:8080"; }
        ];
      };
    };
  };
};
```

### 3. Restricting Route to Local LAN IPs (Middleware)
```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.internal.rule=Host(`admin.local.lan`)"
  - "traefik.http.routers.internal.entrypoints=web"
  # IP whitelist middleware
  - "traefik.http.middlewares.lan-only.ipwhitelist.sourcerange=192.168.1.0/24, 10.0.0.0/8"
  - "traefik.http.routers.internal.middlewares=lan-only"
  - "traefik.http.services.internal.loadbalancer.server.port=8080"
```
