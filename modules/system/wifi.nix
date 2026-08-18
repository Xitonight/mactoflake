{
  flake.nixosModules.wifi =
    { lib, config, ... }:
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
          type = lib.types.attrsOf (lib.types.submodule {
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
          });
          default = { };
          description = "Wifi networks keyed by profile name.";
        };
      };

      config = lib.mkIf cfg.enable {
        networking.networkmanager.ensureProfiles = {
          environmentFiles = [ config.sops.templates."wifi.env".path ];
          profiles = lib.mapAttrs (
            name: net: {
              connection = {
                id = name;
                type = "wifi";
                autoconnect = true;
              };
              wifi.ssid = net.ssid;
              wifi-security = {
                key-mgmt = "wpa-psk";
                psk = "$${envVar name net}";
              };
              ipv4.method = "auto";
              ipv6.method = "auto";
            }
          ) cfg.networks;
        };

        sops.secrets = lib.mapAttrs' (
          name: _:
          lib.nameValuePair "wifi-psk-${name}" { sopsFile = ../../secrets/wifi.yaml; }
        ) cfg.networks;

        sops.templates."wifi.env".content = lib.concatStrings (
          lib.mapAttrsToList (
            name: net: "${envVar name net}=${config.sops.placeholder."wifi-psk-${name}"}\n"
          ) cfg.networks
        );
      };
    };
}
