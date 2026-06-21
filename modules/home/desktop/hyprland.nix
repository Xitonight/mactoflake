{ pkgs, ... }:

{
  # Verbatim Hyprland Lua config (source of truth, ported from ~/.xidots).
  # Linked per-file so the system module's generated monitors.lua can sit
  # alongside (see modules/system/hyprland.nix).
  xdg.configFile."hypr/source".source = ./hypr/source;
  xdg.configFile."hypr/hyprland.lua".source = ./hypr/hyprland.lua;

  home.packages = with pkgs; [
    hyprpolkitagent
    cliphist
    udiskie
    stow
    hyprshot
    grim
    slurp
    playerctl
    brightnessctl
    ddcutil
    wiremix
  ];
}
