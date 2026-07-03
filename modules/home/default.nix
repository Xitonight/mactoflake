{ inputs, ... }:

{
  home.username = "xitonight";
  home.homeDirectory = "/home/xitonight";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  imports = [
    ./btop.nix
    ./fsh
    ./git.nix
    ./gtk.nix
    ./hypr
    ./kitty.nix
    ./lazygit.nix
    ./matugen
    ./nvim
    ./rbw.nix
    ./swaync
    ./tmux.nix
    ./xdg.nix
    ./zen.nix
  ];
}
