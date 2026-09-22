{
  inputs,
  ...
}:
{
  flake.homeModules.gazelle =
    { pkgs, ... }:
    {
      imports = [ inputs.gazelle-tui.homeModules.gazelle ];

      programs.gazelle = {
        enable = true;
        settings.theme = "auto";
      };

      home.packages = [
        inputs.gazelle-tui.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
}
