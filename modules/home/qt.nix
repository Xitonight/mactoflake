{ username, ... }:
let
  mkQtctSettings = colorsDir: {
    Appearance = {
      color_scheme_path = "${colorsDir}/matugen.conf";
      custom_palette = true;
      icon_theme = "Papirus-Dark";
      standard_dialogs = "gtk3";
      style = "Fusion";
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
    platformTheme.name = "qtct";
    qt5ctSettings = mkQtctSettings "/home/${username}/.config/qt5ct/colors";
    qt6ctSettings = mkQtctSettings "/home/${username}/.config/qt6ct/colors";
  };

  home.sessionVariables = {
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
  };
}
