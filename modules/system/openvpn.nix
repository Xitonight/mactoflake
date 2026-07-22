{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.mactoflake.network.openvpn;
in
{
  options.mactoflake.network.openvpn = {
    enable = lib.mkEnableOption "OpenVPN client/server instances";

    servers = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          configFile = lib.mkOption {
            type = lib.types.str;
            example = "/etc/openvpn/work.ovpn";
            description = ''
              Absolute path to an OpenVPN config file (.ovpn/.conf) kept
              outside the Nix store. Configs are referenced verbatim via the
              openvpn `config' directive, so files may contain secrets
              (certs, keys, auth-user-pass credentials) without being copied
              into the world-readable store.
            '';
          };

          autoStart = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = ''
              Start this instance automatically at boot (creates a
              openvpn-<name> systemd service wanted by multi-user.target).
            '';
          };
        };
      });
      default = { };
      example = lib.literalExpression ''
        {
          work = {
            configFile = "/etc/openvpn/work.ovpn";
          };
        }
      '';
      description = "Named OpenVPN instances keyed by service name.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.openvpn3 ];

    services.openvpn.servers = lib.mapAttrs (_: s: {
      inherit (s) autoStart;
      config = "config ${s.configFile}\n";
    }) cfg.servers;
  };
}
