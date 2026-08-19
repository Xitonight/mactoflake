{
  flake.nixosModules.paperless =
    { config, ... }:
    {
      services.paperless = {
        enable = true;
        address = "0.0.0.0";
        passwordFile = config.sops.secrets.paperless-password.path;
        settings = {
          PAPERLESS_OCR_LANGUAGE = "ita+eng";
        };
      };

      sops.secrets.paperless-password.sopsFile = ../../secrets/paperless.yaml;

      networking.firewall.allowedTCPPorts = [ 28981 ];
    };
}
