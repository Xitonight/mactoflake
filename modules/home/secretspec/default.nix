{ pkgs, ... }:

let
  tomlFormat = pkgs.formats.toml { };
in
{
  xdg.configFile."secretspec/config.toml".source = tomlFormat.generate "secretspec-config.toml" {
    defaults = {
      provider = "onepassword";
      profile = "development";
    };
  };
}
