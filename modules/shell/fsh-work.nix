{
  flake.homeModules.fsh-work =
    {
      config,
      flakeDir,
      ...
    }:
    let
      fshDir = "${flakeDir}/modules/shell/fsh/source-work";
      inherit (config.lib.file) mkOutOfStoreSymlink;
    in
    {
      xdg.configFile."fsh".source = mkOutOfStoreSymlink fshDir;
    };
}
