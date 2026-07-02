{ pkgs, ... }:

{
  programs.zsh.enable = true; # installs zsh system-wide (required by defaultUserShell)
  programs.fish.enable = true; # alternative shell; zsh remains the login shell
  users.defaultUserShell = pkgs.zsh;
}
