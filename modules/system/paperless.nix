{
  flake.nixosModules.paperless =
    { config, ... }:
    {
      services.paperless = {
        enable = true;
        configureTika = true;
        address = "0.0.0.0";
        passwordFile = config.sops.secrets.paperless-password.path;
        settings = {
          PAPERLESS_OCR_LANGUAGE = "ita+eng";
          PAPERLESS_FORCE_SCRIPT_NAME = "/paperless";
          PAPERLESS_STATIC_URL = "/paperless/static/";
          PAPERLESS_CSRF_TRUSTED_ORIGINS = [ "https://mactoncino.taila7373f.ts.net" ];
        };
      };

      services.gotenberg.port = 3199;

      sops.secrets.paperless-password.sopsFile = ../../secrets/paperless.yaml;

      networking.firewall.allowedTCPPorts = [ 28981 ];
    };
}
