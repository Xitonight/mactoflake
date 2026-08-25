{
  flake.nixosModules.tguserbot =
    {
      config,
      inputs,
      pkgs,
      ...
    }:
    {
      imports = [ inputs.tguserbot.nixosModules.default ];

      services.tguserbot = {
        enable = true;
        package = inputs.tguserbot.packages.${pkgs.system}.default;
        environmentFile = config.sops.templates.tguserbot-env.path;
      };

      sops.secrets = {
        tguserbot-api-id = {
          sopsFile = ../../secrets/tguserbot.yaml;
          key = "api-id";
        };
        tguserbot-api-hash = {
          sopsFile = ../../secrets/tguserbot.yaml;
          key = "api-hash";
        };
        tguserbot-phone-number = {
          sopsFile = ../../secrets/tguserbot.yaml;
          key = "phone-number";
        };
        tguserbot-tg-password = {
          sopsFile = ../../secrets/tguserbot.yaml;
          key = "tg-password";
        };
      };

      sops.templates.tguserbot-env = {
        restartUnits = [ "tguserbot.service" ];
        content = ''
          API_ID=${config.sops.placeholder.tguserbot-api-id}
          API_HASH=${config.sops.placeholder.tguserbot-api-hash}
          PHONE_NUMBER=${config.sops.placeholder.tguserbot-phone-number}
          TG_PASSWORD=${config.sops.placeholder.tguserbot-tg-password}
        '';
      };
    };
}
