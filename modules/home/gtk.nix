{ pkgs, ... }:

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
      extraCss = ''
        @define-color accent_color #8ecff2;
        @define-color accent_fg_color #001e2b;
        @define-color accent_bg_color #8ecff2;
        @define-color window_bg_color #0f1417;
        @define-color window_fg_color #dfe3e7;
        @define-color headerbar_bg_color #0f1417;
        @define-color headerbar_fg_color #dfe3e7;
        @define-color popover_bg_color #0f1417;
        @define-color popover_fg_color #dfe3e7;
        @define-color view_bg_color #0f1417;
        @define-color view_fg_color #dfe3e7;
        @define-color card_bg_color #0f1417;
        @define-color card_fg_color #dfe3e7;
        @define-color sidebar_bg_color @window_bg_color;
        @define-color sidebar_fg_color @window_fg_color;
        @define-color sidebar_border_color @window_bg_color;
        @define-color sidebar_backdrop_color @window_bg_color;
      '';

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
  };

  gtk4.extraCss = ''
    @define-color accent_color #8ecff2;
    @define-color accent_fg_color #001e2b;
    @define-color accent_bg_color #8ecff2;
    @define-color window_bg_color #0f1417;
    @define-color window_fg_color #dfe3e7;
    @define-color headerbar_bg_color #0f1417;
    @define-color headerbar_fg_color #dfe3e7;
    @define-color popover_bg_color #0f1417;
    @define-color popover_fg_color #dfe3e7;
    @define-color view_bg_color #0f1417;
    @define-color view_fg_color #dfe3e7;
    @define-color card_bg_color #0f1417;
    @define-color card_fg_color #dfe3e7;
    @define-color sidebar_bg_color @window_bg_color;
    @define-color sidebar_fg_color @window_fg_color;
    @define-color sidebar_border_color @window_bg_color;
    @define-color sidebar_backdrop_color @window_bg_color;
  '';

  xdg.configFile = {
    "gtk-3.0/colors.css".source = ./gtk/colors.css;
    "gtk-4.0/colors.css".source = ./gtk/colors.css;
  };
}
