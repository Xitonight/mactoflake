{ pkgs, lib, username, ... }:

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
        "file:///home/${username}/dl/ Downloads"
        "file:///home/${username}/projects/ Projects"
        "file:///home/${username}/pictures/papers/ Wallpapers"
        "file:///home/${username}/.xidots/ Dotfiles"
      ];
    };

    gtk4 = {
      theme = lib.mkForce null;
    };
  };

  home.sessionVariables = {
    XCURSOR_SIZE = "24";
  };
}
