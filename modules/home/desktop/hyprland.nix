{ pkgs, ... }:

{
  # Verbatim Hyprland Lua config (see ./hypr). Not ported to Nix settings on
  # purpose: the Lua DSL is the source of truth (ported from ~/.xidots).
  xdg.configFile."hypr".source = ./hypr;

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
