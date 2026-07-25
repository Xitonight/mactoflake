{
  flake.homeModules.rofi =
    {
      config,
      flakeDir,
      ...
    }:
    let
      rofiDir = "${flakeDir}/modules/desktop/rofi/source";
      inherit (config.lib.file) mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."rofi".source = mkOutOfStoreSymlink rofiDir;
    };
}
