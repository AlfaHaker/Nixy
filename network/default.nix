# network/default.nix - Direct Network Stack Entrypoint
{ ... }:

{
  imports = [
    ./network.nix
    ./firewall.nix
  ];
}
