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
    let
      agent = if osConfig == null then "1password" else osConfig.mactoflake.ssh.agent;
      signingKey = if osConfig == null then null else osConfig.mactoflake.git.signingKey;
    in
    {
      programs.git = {
        enable = true;
        settings = {
          user = {
            name = "Xitonight";
            inherit email;
          };
          safe.directory = "/etc/nixos";
          diff.tool = "delta";
          difftool = {
            prompt = false;
            delta.cmd = "${lib.getExe pkgs.delta} --side-by-side \"$LOCAL\" \"$REMOTE\"";
          };
        };
        signing = {
          signByDefault = signingKey != null;
          format = "ssh";
          signer = lib.mkIf (agent == "1password") (lib.getExe' pkgs._1password-gui "op-ssh-sign");
          key = signingKey;
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
