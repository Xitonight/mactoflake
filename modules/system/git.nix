{ lib, ... }:

{
  options.mactoflake.git.signingKey = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
    description = ''
      SSH public key used by the home-manager git module for commit/tag
      signing via the 1Password SSH agent. Set per-host.
    '';
  };
}
