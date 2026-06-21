{ inputs, pkgs, lib, config, ... }:

let
  cfg = config.flakey.hyprland;
in
{
  options.flakey.hyprland.monitors = lib.mkOption {
    type = lib.types.listOf (lib.types.submodule {
      options = {
        output = lib.mkOption {
          type = lib.types.str;
          example = "eDP-1";
          description = "Monitor output name (run hyprctl monitors to list them).";
        };
        mode = lib.mkOption {
          type = lib.types.str;
          example = "1920x1080@75";
          description = "Resolution and optional refresh rate (e.g. 1920x1080@75), or preferred/highres.";
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
      Per-host Hyprland monitor setup. Generated into the user's
      hypr/monitors.lua and required by hyprland.lua. An empty list leaves
      all monitors to auto-detection (sensible for the QEMU VM).
    '';
  };

  config = {
    programs.hyprland = {
      enable = true;
      withUWSM = true; # wrap Hyprland in a proper systemd graphical session
      # Use the upstream flake's Hyprland build, keeping the portal package in
      # sync with it (see https://wiki.hypr.land/Nix/Hyprland-on-NixOS/).
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage =
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };

    security.polkit.enable = true;

    # Hyprland binary cache — avoids compiling Hyprland from source.
    nix.settings = {
      substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-substituters = [
        "https://hyprland.cachix.org"
      ];
      trusted-public-keys = [
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    # Per-host monitors -> generated Lua, bridged into the home config.
    home-manager.users.xitonight.xdg.configFile."hypr/monitors.lua".text =
      lib.concatMapStringsSep "\n\n" (m:
        "hl.monitor({\n"
        + "  output = \"${m.output}\",\n"
        + "  mode = \"${m.mode}\",\n"
        + "  position = \"${m.position}\",\n"
        + "  scale = ${toString m.scale},\n"
        + "})"
      ) cfg.monitors;
  };
}
