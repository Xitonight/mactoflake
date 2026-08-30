{
  flake.nixosModules.caddy =
    {
      config,
      lib,
      email,
      ...
    }:
    let
      cfg = config.mactoflake.proxy;
    in
    {
      options.mactoflake.proxy = {
        enable = lib.mkEnableOption "Caddy reverse proxy with automatic HTTPS";

        domain = lib.mkOption {
          type = lib.types.str;
          description = "Public domain served by the proxy.";
        };

        vhosts = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                port = lib.mkOption {
                  type = lib.types.port;
                  description = "Upstream port on 127.0.0.1.";
                };
                prefix = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "Path prefix the upstream serves under.";
                };
              };
            }
          );
          default = { };
          description = "Subdomains to serve as <name>.<domain>.";
        };
      };

      config = lib.mkIf cfg.enable {
        services.caddy = {
          enable = true;
          inherit email;
          virtualHosts = lib.mapAttrs' (
            name: v:
            lib.nameValuePair "${name}.${cfg.domain}" {
              extraConfig =
                lib.optionalString (v.prefix != null) ''
                  @unprefixed not path /${v.prefix}/*
                  rewrite @unprefixed /${v.prefix}{uri}
                ''
                + ''
                  reverse_proxy 127.0.0.1:${toString v.port}
                '';
            }
          ) cfg.vhosts;
        };

        networking.firewall.allowedTCPPorts = [
          80
          443
        ];
      };
    };
}
