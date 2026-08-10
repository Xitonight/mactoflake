{
  flake.nixosModules.nh =
    { flakeDir, ... }:
    {
      environment.variables = {
        NH_HOME_FLAKE = "${flakeDir}";
        NH_OS_FLAKE = "${flakeDir}";
      };
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep-since 3d --keep 3";
        flake = "${flakeDir}"; # sets NH_OS_FLAKE variable for you
      };
    };
}
