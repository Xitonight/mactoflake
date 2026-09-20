{
  inputs,
  ...
}:

{
  imports = [ inputs.pre-commit-hooks-nix.flakeModule ];

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      pre-commit.settings.hooks = {
        statix.enable = true;
        nixfmt.enable = true;
      };

      apps = {
        pre-commit-install = {
          type = "app";
          program = "${pkgs.writeShellScript "pre-commit-install" config.pre-commit.installationScript}";
        };

        pre-commit = {
          type = "app";
          program = lib.getExe config.pre-commit.settings.package;
        };
      };
    };
}
