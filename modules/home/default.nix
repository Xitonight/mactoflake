{ inputs, ... }:

{
  home.username = "xitonight";
  home.homeDirectory = "/home/xitonight";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  imports = [ ./git.nix ./gtk.nix ./rbw.nix ./xdg.nix ./zen.nix ];
}
