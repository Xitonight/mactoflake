{ config, flakeDir, ... }:

let
  nvimDir = "${flakeDir}/modules/home/nvim/source";
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  xdg.configFile."nvim".source = mkOutOfStoreSymlink nvimDir;
}
