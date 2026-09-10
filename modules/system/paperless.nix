{
  flake.nixosModules.paperless =
    {
      config,
      lib,
      pkgs,
      ...
    }:
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
          PAPERLESS_CSRF_TRUSTED_ORIGINS = lib.concatStringsSep "," (
            [ "https://mactoncino.taila7373f.ts.net" ]
            ++ lib.optionals config.mactoflake.proxy.enable [
              "https://paperless.${config.mactoflake.proxy.domain}"
            ]
          );
          PAPERLESS_CONSUMER_DELETE_DUPLICATES = true;
        };
      };

      services.gotenberg.port = 3199;

      sops.secrets.paperless-password.sopsFile = ../../secrets/paperless.yaml;
    };
}
