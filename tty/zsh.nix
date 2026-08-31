# tty/zsh.nix - Zsh Shell Configuration
{ config, pkgs, lib, vars, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -lah --color=auto";
      la = "ls -A";
      l = "ls -CF";
      ".." = "cd ..";
      "..." = "cd ../..";
      ports = "ss -tulpn";
      sysrebuild = "sudo nixos-rebuild switch";
      sysboot = "sudo nixos-rebuild boot";
      sysdiff = "nvd diff /run/current-system result";
    };

    interactiveShellInit = ''
      # Shell options
      setopt AUTO_CD
      setopt EXTENDED_GLOB
      setopt NO_BEEP
      setopt HIST_IGNORE_DUPS
      setopt HIST_FIND_NO_DUPS
      setopt HIST_REDUCE_BLANKS

      # Modern colored prompt
      PROMPT='%F{cyan}%n%f@%F{blue}%m%f:%F{yellow}%~%f%F{green}$(%F{red}%(?..%? )%F{green})%f# '
    '';
  };
}
