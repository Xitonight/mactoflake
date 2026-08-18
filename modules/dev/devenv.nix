{
  flake.homeModules.devenv =
    {
      pkgs,
      inputs,
      ...
    }:
    {
      programs.devenv = {
        enable = true;
        enableZshIntegration = true;
        package = inputs.devenv.packages.${pkgs.stdenv.hostPlatform.system}.devenv;
      };
    };
}
