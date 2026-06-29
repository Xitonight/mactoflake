{ lib, config, ... }:

let cfg = config.flakey.network.tailscale;
in {
  options.flakey.network.tailscale = {
    enable = lib.mkEnableOption "Tailscale mesh VPN";

    isExitNode = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Allow this host to act as a Tailscale exit node / subnet router.
        Enables IP forwarding on the host.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      openFirewall = true;
    };

    networking.ipForward = lib.mkIf cfg.isExitNode true;
  };
}
