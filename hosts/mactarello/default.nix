{
  self,
  inputs,
  lib,
  ...
}:

{
  flake.nixosConfigurations.mactarello = inputs.nixpkgs.lib.nixosSystem {
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
      self.nixosModules.containers
      self.nixosModules.media
      self.nixosModules.arr
      self.nixosModules.slskd
      self.nixosModules.droppedneedle
      self.nixosModules.paperless
      self.nixosModules.pihole
      self.nixosModules.vaultwarden
      self.nixosModules.glance
      self.nixosModules.homepage
      self.nixosModules.printing
      self.nixosModules.tguserbot
      self.nixosModules.caddy
      self.nixosModules.home-manager
      {
        home-manager.users.${self.const.username} = {
          imports = self.homeImportsServer;
        };
        networking.hostName = "mactarello";

        mactoflake = {
          proxy = {
            enable = true;
            domain = "mactonet.com";
            vhosts = {
              drome.port = 4533;
              paperless = {
                port = 28981;
                prefix = "paperless";
              };
              jelly.port = 8096;
              vault.port = 8222;
              needle.port = 8688;
            };
          };

          printing = {
            enable = true;
            openFirewall = false;
          };

          containers = {
            enable = true;
            rootless = false;
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

        services.homepage-dashboard = {
          settings.layout.Gaming = {
            tab = "Dashboard";
            header = false;
            style = "row";
            columns = 1;
          };

          services = [
            {
              Gaming = [
                {
                  atm10 = {
                    icon = "minecraft.png";
                    description = "Modpack server on mactoncino";
                    widget = {
                      type = "gamedig";
                      serverType = "minecraft";
                      url = "udp://mactoncino:25565";
                      fields = [
                        "status"
                        "currentPlayers"
                        "ping"
                      ];
                    };
                  };
                }
              ];
            }
          ];
        };

        networking.firewall.interfaces = {
          tailscale0 = {
            allowedTCPPorts = [
              22
              53
              631
              3000
              4533
              5030
              7878
              8080
              8081
              8082
              8096
              8222
              8688
              8989
              9696
              28981
            ];
            allowedUDPPorts = [ 53 ];
          };
          eno1 = {
            allowedTCPPorts = [
              22
              53
              631
            ];
            allowedUDPPorts = [ 53 ];
          };
          wlp6s0 = {
            allowedTCPPorts = [
              22
              53
              631
            ];
            allowedUDPPorts = [ 53 ];
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
