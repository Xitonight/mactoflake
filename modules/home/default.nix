{ inputs, ... }:

{
  home.username = "xitonight";
  home.homeDirectory = "/home/xitonight";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  imports = [
    ./btop.nix
    ./git.nix
    ./gtk.nix
    ./hypr
    ./nvim
    ./rbw.nix
    ./tmux.nix
    ./xdg.nix
    ./zen.nix
  ];
}
