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
      self.nixosModules.arr
      self.nixosModules.slskd
      self.nixosModules.paperless
      self.nixosModules.pihole
      self.nixosModules.vaultwarden
      self.nixosModules.home-assistant
      self.nixosModules.glance
      self.nixosModules.homepage
      self.nixosModules.n8n
      self.nixosModules.printing
      self.nixosModules.caddy
      self.nixosModules.tguserbot
      self.nixosModules.home-manager
      {
        home-manager.users.${self.const.username} = {
          imports = self.homeImportsServer;
        };
        networking.hostName = "mactoncino";

        mactoflake = {
          proxy = {
            enable = true;
            domain = "mactonet.com";
            vhosts = {
              music = {
                port = 4533;
                prefix = "navidrome";
              };
              paperless = {
                port = 28981;
                prefix = "paperless";
              };
              vault.port = 8222;
            };
          };

          printing = {
            enable = true;
            openFirewall = true;
          };

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
