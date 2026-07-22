{
  config,
  pkgs,
  lib,
  flakeDir,
  monitorsConfig,
  ...
}:

let
  hyprDir = "${flakeDir}/modules/home/hypr/source";
  sourceDir = "${hyprDir}/source";

  inherit (config.lib.file) mkOutOfStoreSymlink;

  monitorsLua =
    if monitorsConfig == [ ] then
      mkOutOfStoreSymlink "${sourceDir}/monitors.lua"
    else
      pkgs.writeText "monitors.lua" (
        lib.concatMapStringsSep "\n\n" (m: ''
          hl.monitor({
            output = "${m.output}",
            mode = "${m.mode}",
            position = "${m.position}",
            scale = ${toString m.scale},
            transform = ${toString m.transform}
          })
        '') monitorsConfig
      );

  sourceFiles = builtins.readDir ./source/source;
  nonMonitorFiles = lib.filterAttrs (name: type: name != "monitors.lua") sourceFiles;

  makeEntry = name: {
    name = "hypr/source/${name}";
    value.source = mkOutOfStoreSymlink "${sourceDir}/${name}";
  };
in
{
  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";

    GDK_BACKEND = "wayland,x11,*";
    SDL_VIDEODRIVER = "wayland";
  };

  xdg.configFile = lib.listToAttrs (map makeEntry (lib.attrNames nonMonitorFiles)) // {
    "hypr/hyprland.lua".source = mkOutOfStoreSymlink "${hyprDir}/hyprland.lua";
    "hypr/source/monitors.lua".source = monitorsLua;
  };
}
