{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  git-hooks.hooks = {
    statix.enable = true;
    nixfmt.enable = true;
  };
}
