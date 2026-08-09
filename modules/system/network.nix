{
  flake.nixosModules.network =
    { username, ... }:
    {
      networking.networkmanager.enable = true;

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = [ username ];
          MaxAuthTries = 3;
          LoginGraceTime = "30";
        };
      };
    };
}
