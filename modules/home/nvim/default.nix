{
  config,
  flakeDir,
  pkgs,
  ...
}:

let
  nvimDir = "${flakeDir}/modules/home/nvim/source";
  inherit (config.lib.file) mkOutOfStoreSymlink;
in
{
  home.packages = with pkgs; [
    lsof

    # Global LSPs / formatters

    # Nix
    nixd
    nixfmt

    # Lua
    lua-language-server

    #
    vscode-json-languageserver
  ];

  xdg.configFile."nvim".source = mkOutOfStoreSymlink nvimDir;
}
