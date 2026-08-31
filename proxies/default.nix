# proxies/default.nix - Reverse Proxy Stack Entrypoint
{ lib, vars, ... }:

{
  imports =
    if vars.proxy == "caddy" then [ ./caddy.nix ]
    else if vars.proxy == "traefik" then [ ./traefik.nix ]
    else if vars.proxy == "nginx" then [ ./nginx.nix ]
    else [ ];
}
