{
  flake.nixosModules.sudo =
    { username, ... }:
    {
      users.users."${username}".extraGroups = [ "wheel" ];
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
