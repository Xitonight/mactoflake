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
    # Packages required by plugins
    lsof

    # Global LSPs / formatters

    # Nix
    nixd
    nixfmt

    # Lua
    lua-language-server
    stylua

    # Json
    vscode-json-languageserver
    prettierd

    # TOML
    taplo
  ];

  xdg.configFile."nvim".source = mkOutOfStoreSymlink nvimDir;
}
