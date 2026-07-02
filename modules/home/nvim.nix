{ config, flakeDir, ... }:

let
  nvimDir = "${flakeDir}/modules/home/nvim";
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  xdg.configFile."nvim".source = mkOutOfStoreSymlink nvimDir;
}
