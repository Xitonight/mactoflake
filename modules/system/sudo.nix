{
  flake.nixosModules.sudo =
    { username, ... }:
    {
      security.sudo.extraRules = [
        {
          users = [ username ];
          runAs = "ALL:ALL";
          commands = [
            {
              command = "ALL";
              options = [
                "NOPASSWD"
                "SETENV"
              ];
            }
          ];
        }
      ];
    };
}
