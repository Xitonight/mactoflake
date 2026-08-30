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
          DOMAIN = "https://vault.mactonet.com";
          ROCKET_ADDRESS = "0.0.0.0";
          ROCKET_PORT = 8222;
          SIGNUPS_ALLOWED = false;
          SHOW_PASSWORD_HINT = false;
          SMTP_HOST = "smtp.resend.com";
          SMTP_PORT = 587;
          SMTP_SECURITY = "starttls";
          SMTP_USERNAME = "resend";
          SMTP_FROM = "vault@mactonet.com";
          SMTP_FROM_NAME = "Vaultwarden";
        };
      };

      sops = {
        secrets = {
          vaultwarden-admin-token = {
            sopsFile = ../../secrets/vaultwarden.yaml;
            key = "admin-token";
          };
          vaultwarden-smtp-password = {
            sopsFile = ../../secrets/vaultwarden.yaml;
            key = "smtp-password";
          };
        };
        templates.vaultwarden-env = {
          owner = "vaultwarden";
          restartUnits = [ "vaultwarden.service" ];
          content = ''
            ADMIN_TOKEN=${config.sops.placeholder.vaultwarden-admin-token}
            SMTP_PASSWORD=${config.sops.placeholder.vaultwarden-smtp-password}
          '';
        };
      };
    };
}
