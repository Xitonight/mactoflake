{ config, flakeDir, pkgs, ... }:

let
  nvimDir = "${flakeDir}/modules/home/nvim/source";
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  home.packages = [
    pkgs.lsof
  ];

  xdg.configFile."nvim".source = mkOutOfStoreSymlink nvimDir;
}
