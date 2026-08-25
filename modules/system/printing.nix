{
  flake.nixosModules.printing =
    { lib, config, ... }:
    let
      cfg = config.mactoflake.printing;
    in
    {
      options.mactoflake.printing = {
        enable = lib.mkEnableOption "CUPS printing server";

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Open firewall port 631 for LAN printing and web UI access.";
        };
      };

      config = lib.mkIf cfg.enable {
        services.printing = {
          enable = true;
          listenAddresses = [ "*:631" ];
          allowFrom = [ "all" ];
          browsing = true;
          inherit (cfg) openFirewall;
        };

        services.avahi = {
          enable = true;
          nssmdns4 = true;
        };
      };
    };
}
