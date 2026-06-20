{ inputs, pkgs, ... }:

{
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
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    trusted-users = [
      "root" "@wheel"
    ];
  };
}
