# containers/default.nix - Container Stack Entrypoint
#
# Docker & Incus Coexistence:
# - Both stacks can be enabled simultaneously without conflict.
# - Docker runs microservices and OCI containers via dockerd (overlay2).
# - Incus runs system containers (LXC) and full virtual machines (KVM).
# - Bridge routing (docker0 and incusbr0) and IP forwarding are managed in `network/`.
{ lib, vars, ... }:

{
  imports =
    (
      if (vars.containers ? docker && vars.containers.docker)
      then [ ./docker.nix ]
      else [ ]
    )
    ++ (if (vars.containers ? incus && vars.containers.incus) then [ ./incus.nix ] else [ ]);
}
