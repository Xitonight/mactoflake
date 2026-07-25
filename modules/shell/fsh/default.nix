{
  flake.homeModules.fsh =
    {
      config,
      flakeDir,
      ...
    }:
    let
      fshDir = "${flakeDir}/modules/shell/fsh/source";
      inherit (config.lib.file) mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."fsh".source = mkOutOfStoreSymlink fshDir;
    };
}
