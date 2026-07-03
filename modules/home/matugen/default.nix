{
  config,
  flakeDir,
  ...
}:

let
  matugenDir = "${flakeDir}/modules/home/matugen/source";
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  xdg.configFile."matugen".source = mkOutOfStoreSymlink matugenDir;
}
