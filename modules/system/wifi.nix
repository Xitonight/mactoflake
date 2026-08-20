{
  flake.nixosModules.wifi =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      cfg = config.mactoflake.network.wifi;

      envVar =
        name: net:
        if net.pskEnvVar != null then
          net.pskEnvVar
        else
          "${lib.replaceStrings [ "-" ] [ "_" ] (lib.toUpper name)}_PSK";
    in
    {
      options.mactoflake.network.wifi = {
        enable = lib.mkEnableOption "declarative NetworkManager wifi profiles";

        networks = lib.mkOption {
          type = lib.types.attrsOf (
            lib.types.submodule {
              options = {
                ssid = lib.mkOption {
                  type = lib.types.str;
                  description = "SSID to connect to.";
                };

                pskEnvVar = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = ''
                    Environment variable name holding the PSK in the sops
                    template. Defaults to <NAME>_PSK (uppercased, dashes to
                    underscores).
                  '';
                };
              };
            }
          );
          default = { };
          description = "Wifi networks keyed by profile name.";
        };
      };

      config =
        let
          nmBin = "${config.networking.networkmanager.package}/bin";

          profiles = lib.mapAttrsToList (name: net: {
            inherit name;
            var = envVar name net;
            subst = "$" + envVar name net;
            secret = config.sops.secrets."wifi-psk-${name}".path;
            template = pkgs.writeText "${name}.nmconnection" (
              lib.generators.toINI { } {
                connection = {
                  id = name;
                  type = "wifi";
                  autoconnect = true;
                };
                wifi.ssid = net.ssid;
                wifi-security = {
                  key-mgmt = "wpa-psk";
                  psk = "$" + envVar name net;
                };
                ipv4.method = "auto";
                ipv6.method = "auto";
              }
            );
          }) cfg.networks;
        in
        lib.mkIf cfg.enable {
          sops.secrets = lib.mapAttrs' (
            name: _:
            lib.nameValuePair "wifi-psk-${name}" {
              sopsFile = ../../secrets/wifi.yaml;
              restartUnits = [ "wifi-profiles.service" ];
            }
          ) cfg.networks;

          systemd.services.wifi-profiles = {
            description = "Render NetworkManager wifi profiles from sops secrets";
            wantedBy = [ "multi-user.target" ];
            before = [ "network-online.target" ];
            after = [
              "NetworkManager.service"
              "sops-install-secrets.service"
            ];
            wants = [ "NetworkManager.service" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
              UMask = "0177";
            };
            script = ''
              install -d -m 700 /run/NetworkManager/system-connections
            ''
            + lib.concatMapStringsSep "\n" (p: ''
              if [ ! -s ${lib.escapeShellArg p.secret} ]; then
                echo "wifi-profiles: secret missing or empty: ${p.secret}" >&2
                exit 1
              fi
              export ${p.var}="$(cat ${lib.escapeShellArg p.secret})"
              ${pkgs.envsubst}/bin/envsubst ${lib.escapeShellArg p.subst} < ${lib.escapeShellArg "${p.template}"} > /run/NetworkManager/system-connections/${lib.escapeShellArg "${p.name}.nmconnection"}
              unset ${p.var}
            '') profiles
            + ''

              ${nmBin}/nmcli connection reload
            '';
          };
        };
    };
}
