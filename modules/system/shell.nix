{ pkgs, ... }:

{
  programs.zsh.enable = true; # installs zsh system-wide (required by defaultUserShell)
  users.defaultUserShell = pkgs.zsh;
}
