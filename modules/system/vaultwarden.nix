{
  flake.nixosModules.vaultwarden =
    { config, ... }:
    {
      services.vaultwarden = {
        enable = true;
        dbBackend = "sqlite";
        backupDir = "/var/backup/vaultwarden";
        environmentFile = config.sops.templates.vaultwarden-env.path;
        config = {
          DOMAIN = "http://mactoncino:8222";
          ROCKET_ADDRESS = "0.0.0.0";
          ROCKET_PORT = 8222;
          SIGNUPS_ALLOWED = true;
          SHOW_PASSWORD_HINT = false;
        };
      };

      sops.secrets.vaultwarden-admin-token = {
        sopsFile = ../../secrets/vaultwarden.yaml;
        key = "admin-token";
      };

      sops.templates.vaultwarden-env = {
        owner = "vaultwarden";
        restartUnits = [ "vaultwarden.service" ];
        content = ''
          ADMIN_TOKEN=${config.sops.placeholder.vaultwarden-admin-token}
        '';
      };

      networking.firewall.allowedTCPPorts = [ 8222 ];
    };
}
