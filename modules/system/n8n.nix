{
  flake.nixosModules.n8n =
    { config, ... }:
    {
      services.n8n = {
        enable = false;
        openFirewall = true;
        environment = {
          WEBHOOK_URL = "http://mactoncino:5678/";
          N8N_SECURE_COOKIE = false;
          N8N_ENCRYPTION_KEY_FILE = config.sops.secrets."n8n-encryption-key".path;
          N8N_RUNNERS_AUTH_TOKEN_FILE = config.sops.secrets."n8n-runners-auth-token".path;
        };
        taskRunners.enable = true;
      };

      sops.secrets = {
        n8n-encryption-key = {
          sopsFile = ../../secrets/n8n.yaml;
          key = "encryption-key";
        };
        n8n-runners-auth-token = {
          sopsFile = ../../secrets/n8n.yaml;
          key = "runners-auth-token";
        };
      };
    };
}
