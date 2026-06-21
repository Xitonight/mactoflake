{ pkgs, ... }:

{
  # NOTE: intentionally NOT using programs.zathura here — it would write a
  # read-only zathurarc into the store and clash with matugen, which owns that
  # file (regenerated from templates/colors-zathura on wallpaper change).
  home.packages = [ pkgs.zathura ];
}
