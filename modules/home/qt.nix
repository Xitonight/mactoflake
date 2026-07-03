let
  mkQtctSettings = colorsDir: {
    Appearance = {
      color_scheme_path = "${colorsDir}/matugen.conf";
      custom_palette = true;
      icon_theme = "Papirus-Dark";
      standard_dialogs = "xdgdesktopportal";
    };
    Fonts = {
      fixed = "\"CaskaydiaCove Nerd Font Mono,12\"";
      general = "\"Sans,14\"";
    };
  };
in
{
  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    qt5ctSettings = mkQtctSettings "~/.config/qt5ct/colors";
    qt6ctSettings = mkQtctSettings "~/.config/qt6ct/colors";
  };
}
