{ lib, ... }:

let swayncDir = ./swaync;
in {
  services.swaync = {
    enable = true;
    settings = lib.importJSON "${swayncDir}/config.json";
    style = "${swayncDir}/style.css";
  };

  # style.css @imports three files from styles/: colors.css (matugen-generated,
  # not shipped), plus the static control-center.css and notification.css.
  xdg.configFile = {
    "swaync/styles/control-center.css".source =
      "${swayncDir}/styles/control-center.css";
    "swaync/styles/notification.css".source =
      "${swayncDir}/styles/notification.css";
  };
}
