{
  pkgs,
  inputs,
  ...
}:

{
  programs.devenv = {
    enable = true;
    enableZshIntegration = true;
    package = inputs.devenv.packages.${pkgs.system}.devenv;
  };
}
