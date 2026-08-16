{
  flake.nixosModules.network =
    { username, ... }:
    {
      networking.networkmanager.enable = true;
      users.users."${username}" = {
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEVODpv0S1p5R9fCHeEy8AZTHjnFuVdB3UN6CNlyGuOt mactone"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOx7KW5d4Xtx3fvBDCSeBylB5hTPYIzMB/ss7qJwva/ mactopad"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA5VCATBzbOJajXJSgW8OvBiSn6MOB5vGttNBtKSXlKG mactoncino"
        ];
        extraGroups = [ "networkmanager" ];
      };

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
