{ pkgs, lib, ... }:

{
  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };

    font = {
      name = "Sans";
      size = 14;
    };

    colorScheme = "dark";

    gtk3 = {
      extraConfig = {
        gtk-decoration-layout = "icon:minimize,maximize,close";
        gtk-enable-animations = true;
        gtk-primary-button-warps-slider = false;
      };

      bookmarks = [
        "file:///home/xitonight/Downloads Downloads"
        "file:///home/xitonight/Projects/ Projects"
        "file:///home/xitonight/Pictures/Wallpapers/ Wallpapers"
        "file:///home/xitonight/.xidots/ dots"
      ];
    };

    gtk4 = { theme = lib.mkForce null; };
  };
}
