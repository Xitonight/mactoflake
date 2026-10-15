{
  flake.nixosModules.seerr = {
    services.seerr = {
      enable = true;
      port = 5055;
    };
  };
}
