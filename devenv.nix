{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  # https://devenv.sh/packages/
  packages = with pkgs; [
    git
  ];

  git-hooks.hooks = {
    statix.enable = true;
    nixfmt.enable = true;
  };

  # https://devenv.sh/scripts/
  scripts = {
    sync.exec = ''
      set -euo pipefail

      host="''${1:-mactoncino}"

      echo "==> Syncing flake checkout on $host"
      ssh "$host" 'git -C ~/.mactoflake pull --ff-only'
    '';
  };
}
