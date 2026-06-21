{ pkgs, ... }:

{
  # Matugen is the keystone of the theming setup: on wallpaper change it
  # regenerates ~15 color files (GTK/Qt/Kitty/Hyprland/Rofi/Swaync/Zathura/Cava/
  # pywal) from the templates below. awww is the wallpaper daemon that triggers
  # it. Until `matugen image <wallpaper>` runs once, the color files are absent
  # and the apps fall back to defaults — this is expected (see MIGRATION.md §2).
  home.packages = with pkgs; [ matugen awww pywal ];

  xdg.configFile = {
    "matugen/config.toml".source = ./matugen/config.toml;
    "matugen/templates".source = ./matugen/templates;
  };
}
