{
  flake.nixosModules.home-assistant = {
    services.home-assistant = {
      enable = true;
      extraComponents = [
        "default_config"
        "pi_hole"
        "met"
      ];
      config = {
        homeassistant = {
          name = "mactoncino";
          latitude = 41.9028;
          longitude = 12.4964;
          unit_system = "metric";
        };
      };
    };
  };
}
