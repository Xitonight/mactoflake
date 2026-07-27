{
  flake.nixosModules.hyprland =
    {
      inputs,
      pkgs,
      lib,
      ...
    }:
    {
      options.mactoflake.hyprland.monitors = lib.mkOption {
        type = lib.types.listOf (
          lib.types.submodule {
            options = {
              output = lib.mkOption {
                type = lib.types.str;
                example = "eDP-1";
                description = "Monitor output name.";
              };
              mode = lib.mkOption {
                type = lib.types.str;
                example = "1920x1080@75";
                description = "Resolution and optional refresh rate.";
              };
              position = lib.mkOption {
                type = lib.types.str;
                default = "auto";
                description = "Monitor position.";
              };
              scale = lib.mkOption {
                type = lib.types.either lib.types.int lib.types.float;
                default = 1;
                description = "Scale factor.";
              };
              transform = lib.mkOption {
                type = lib.types.int;
                default = 0;
                description = "Transform factor (monitor rotation)";
              };
            };
          }
        );
        default = [ ];
        description = ''
          Per-host Hyprland monitor setup. Passed to home-manager to generate
          monitors.lua. Empty list falls back to the repo's monitors.lua.
        '';
      };

      config = {
        programs.hyprland = {
          enable = true;
          withUWSM = true;
          xwayland.enable = true;
          package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
          portalPackage =
            inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        };

        xdg.portal = {
          enable = true;
          xdgOpenUsePortal = true;
          extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        };

        services.gnome.gnome-keyring.enable = true;
        security.polkit.enable = true;
      };
    };

  flake.homeModules.hyprland =
    {
      config,
      pkgs,
      lib,
      flakeDir,
      monitorsConfig,
      ...
    }:
    let
      hyprDir = "${flakeDir}/modules/desktop/hyprland/source";
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
    };
}
