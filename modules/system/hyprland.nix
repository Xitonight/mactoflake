{ inputs, pkgs, lib, config, ... }:

let
  monitorsLua = pkgs.writeText "monitors.lua" (
    lib.concatMapStringsSep "\n\n" (m:
      ''
        hl.monitor({
      '' + "  output = \"${m.output}\",\n"
      + "  mode = \"${m.mode}\",\n"
      + "  position = \"${m.position}\",\n"
      + "  scale = ${toString m.scale},\n" + "})"
    ) config.flakey.hyprland.monitors
  );
in {
  options.flakey.hyprland.monitors = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        output = lib.mkOption {
          type = lib.types.str;
          example = "eDP-1";
          description = "Monitor output name.";
        };
        mode = lib.mkOption {
          type = lib.types.str;
          example = "1920x1080@75";
          description =
            "Resolution and optional refresh rate (e.g. 1920x1080@75).";
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
      };
    });
    default = [ ];
    description = ''
      Per-host Hyprland monitor setup. Generates a monitors.lua symlinked into
      ~/.config/hypr/monitors.lua. An empty list skips the file entirely.
    '';
  };

  config = {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
      package =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
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

    nix.settings = {
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      trusted-users = [ "root" "@wheel" ];
    };

    # Per-host monitors.lua — the rest of ~/.config/hypr/ comes from the user's
    # bare dotfiles repo.
    hjem.users.xitonight.xdg.config.files."hypr/source/monitors.lua" =
      lib.mkIf (config.flakey.hyprland.monitors != [ ]) {
        source = monitorsLua;
        clobber = true;
      };
  };
}
