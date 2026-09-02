# tty/default.nix - Shell & Terminal Stack Coordinator
{ lib, ... }:
let
  vars = import ../variables.nix;
in {
  imports =
    (if vars.shell == "bash" then [ ./bash.nix ]
     else if vars.shell == "zsh" then [ ./zsh.nix ]
     else if vars.shell == "fish" then [ ./fish.nix ]
     else [ ])
    ++ (if (vars ? header && vars.header) then [ ./header.nix ] else [ ]);
}
