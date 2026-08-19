{
  self,
  inputs,
  lib,
  ...
}:

{
  flake.nixosConfigurations.mactoncino = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = {
      inherit inputs;
      inherit (self.const)
        username
        flakeDir
        papersDir
        email
        ;
    };
    modules = [
      ./hardware-configuration.nix
      ./disks.nix
      self.nixosModules.base
      self.nixosModules.media
      self.nixosModules.paperless
      self.nixosModules.homepage
      self.nixosModules.home-assistant
      self.nixosModules.home-manager
      {
        home-manager.users.${self.const.username} = {
          imports = self.homeImportsServer;
        };
        networking.hostName = "mactoncino";

        mactoflake = {
          boot = {
            loader = "systemd-boot";
            silent-boot = true;
          };

          network = {
            tailscale = {
              enable = true;
              enableSSH = true;
            };

            wifi = {
              enable = true;
              networks = {
                Mactofi.ssid = "Mactofi";
                Mactofi-5G.ssid = "Mactofi 5G";
              };
            };
          };
        };

        boot.loader.timeout = 0;
        boot.loader.systemd-boot = {
          configurationLimit = 3;
          editor = false;
        };

        systemd.services.NetworkManager-wait-online.enable = false;

        home-manager.extraSpecialArgs.monitorsConfig = lib.mkForce [ ];
      }
    ];
  };
}
