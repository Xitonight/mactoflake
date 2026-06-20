{ inputs, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
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
      "https://cache.nixos.org/"
      "https://hyprland.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:7a5bdxH7ZqYCkf2sZQCinzM6vZ+yw5YkgZQyFtPpf5M="
    ];
  };
}
