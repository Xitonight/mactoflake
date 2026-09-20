{
  flake.homeModules.devenv =
    {
      pkgs,
      inputs,
      lib,
      ...
    }:
    {
      programs =
        let
          inherit (lib) getExe;
          package = inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv;
        in
        {
          devenv = {
            enable = true;
            enableZshIntegration = false;
            inherit package;
          };
        };
    };
}
