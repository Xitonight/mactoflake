{
  flake.nixosModules.home-assistant =
    { pkgs, ... }:
    {
      services.home-assistant = {
        enable = true;
        package =
          (pkgs.home-assistant.override {
            extraPackages = ps: [
              ps.isal
              ps.zlib-ng
            ];
          }).overrideAttrs
            (oldAttrs: {
              doInstallCheck = false;
            });
        extraComponents = [
          "default_config"
          "pi_hole"
          "met"
          "tplink"
        ];
        config = {
          homeassistant = {
            name = "mactoncino";
            latitude = 41.9028;
            longitude = 12.4964;
            unit_system = "metric";
          };
          automation = "!include automations.yaml";
          scene = "!include scenes.yaml";
          script = "!include scripts.yaml";
        };
      };

      systemd.tmpfiles.rules = [
        "f /var/lib/hass/automations.yaml 0600 hass hass - []"
        "f /var/lib/hass/scenes.yaml 0600 hass hass - []"
        "f /var/lib/hass/scripts.yaml 0600 hass hass - []"
      ];
    };
}
