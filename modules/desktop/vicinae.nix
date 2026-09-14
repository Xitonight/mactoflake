{
  inputs,
  ...
}:
{
  flake.homeModules.vicinae =
    { pkgs, ... }:
    {
      imports = [ inputs.vicinae.homeManagerModules.default ];

      programs.vicinae = {
        enable = true;
        package = pkgs.vicinae;
        enableFirefoxIntegration = false;
        enableChromeIntegration = false;
        systemd = {
          enable = true;
          environment = {
            USE_LAYER_SHELL = 1;
          };
        };
        settings = {
          theme = {
            light.name = "matugen";
            dark.name = "matugen";
          };
        };
      };
    };
}
