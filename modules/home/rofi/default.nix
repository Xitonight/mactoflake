{
  config,
  flakeDir,
  ...
}:

let
  rofiDir = "${flakeDir}/modules/home/rofi/source";
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  xdg.configFile."rofi".source = mkOutOfStoreSymlink rofiDir;
}
