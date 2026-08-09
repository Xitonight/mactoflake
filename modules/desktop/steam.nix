{
  flake.nixosModules.steam = {
    programs = {
      gamemode.enable = true;
      steam = {
        enable = true;
        dedicatedServer.openFirewall = false;
      };
    };
  };
}
