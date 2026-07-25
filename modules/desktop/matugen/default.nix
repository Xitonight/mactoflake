{
  flake.homeModules.matugen =
    {
      config,
      flakeDir,
      ...
    }:
    let
      matugenDir = "${flakeDir}/modules/desktop/matugen/source";
      inherit (config.lib.file) mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."matugen".source = mkOutOfStoreSymlink matugenDir;
    };
}
