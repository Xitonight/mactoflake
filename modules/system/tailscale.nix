{
  flake.nixosModules.tailscale =
    { lib, config, ... }:
    let
      cfg = config.mactoflake.network.tailscale;
      hostName = config.networking.hostName;
      authKeyHosts = [
        "mactone"
        "mactoncino"
        "mactopad"
      ];
      hasAuthKey = builtins.elem hostName authKeyHosts;
    in
    {
      options.mactoflake.network.tailscale = {
        enable = lib.mkEnableOption "Tailscale mesh VPN";

        enableSSH = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Enable Tailscale SSH (sets --ssh flag on tailscale up).
            Allows Tailscale nodes to SSH into this host using Tailscale auth.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        services.tailscale = {
          enable = true;
          openFirewall = true;
          authKeyFile = lib.mkIf hasAuthKey config.sops.secrets."${hostName}-key".path;
          extraSetFlags = lib.mkIf cfg.enableSSH [ "--ssh" ];
        };

        sops.secrets."${hostName}-key" = lib.mkIf hasAuthKey {
          sopsFile = ../../secrets/tailscale.yaml;
        };
      };
    };
}
