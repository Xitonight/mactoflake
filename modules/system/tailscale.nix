{ lib, config, ... }:

let
  cfg = config.flakey.network.tailscale;
in
{
  options.flakey.network.tailscale = {
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
      # Only works when using auth keys (yet to be setup)
      # extraUpFlags = lib.mkIf cfg.enableSSH [ "--ssh" ];
      extraSetFlags = lib.mkIf cfg.enableSSH [ "--ssh" ];
    };
  };
}
