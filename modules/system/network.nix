{
  flake.nixosModules.network = {
    networking.networkmanager.enable = true;
    services.openssh.enable = true;
  };
}
