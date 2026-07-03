{
  config,
  flakeDir,
  ...
}:

let
  fshDir = "${flakeDir}/modules/home/fsh/source";
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  xdg.configFile."fsh".source = mkOutOfStoreSymlink fshDir;
}
