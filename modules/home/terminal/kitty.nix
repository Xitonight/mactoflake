{ pkgs, ... }:

{
  home.packages = [ pkgs.kitty ];

  # colors.conf is matugen-generated (Phase 2); shipped config omits the include.
  xdg.configFile."kitty/kitty.conf".source = ./kitty.conf;
}
