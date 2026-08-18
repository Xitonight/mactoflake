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
    deploy-rs
  ];

  git-hooks.hooks = {
    statix.enable = true;
    nixfmt.enable = true;
  };

  # https://devenv.sh/scripts/
  scripts.deploy.exec = ''
    set -euo pipefail

    host="''${1:-mactoncino}"

    echo "==> Checking working tree"
    if [ -n "$(git status --porcelain)" ]; then
      echo "Working tree is dirty. Commit your changes first." >&2
      exit 1
    fi

    echo "==> Pushing to origin"
    git push

    echo "==> Deploying to $host"
    deploy-rs ".#$host"

    echo "==> Syncing flake checkout on $host"
    ssh "$host" 'git -C ~/.mactoflake pull --ff-only'
  '';
}
