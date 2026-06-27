{ inputs, ... }:

{
  home.username = "xitonight";
  home.homeDirectory = "/home/xitonight";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  imports = [ ./gtk.nix ./zen.nix ];
}
