{
  flake.nixosModules.git =
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
    };

  flake.homeModules.git =
    {
      pkgs,
      lib,
      osConfig,
      email,
      ...
    }:
    {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Xitonight";
            inherit email;
          };
          safe.directory = "/etc/nixos";
        };
        signing = {
          signByDefault = true;
          format = "ssh";
          signer = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
          key = osConfig.mactoflake.git.signingKey;
        };
      };

      programs.delta = {
        enable = true;
        options = {
          line-numbers = true;
          navigate = true;
          side-by-side = true;
          syntax-theme = "base16";
        };
      };
    };
}
