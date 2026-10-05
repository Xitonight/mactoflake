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
      self.nixosModules.base
      self.nixosModules.containers
      self.nixosModules.minecraft
      self.nixosModules.home-manager
      {
        home-manager.users.${self.const.username} = {
          imports = self.homeImportsServer;
        };
        networking.hostName = "mactoncino";

        mactoflake = {
          containers = {
            enable = true;
            rootless = false;
          };

          minecraft.servers = {
            atm10 = {
              enable = true;
              slug = "all-the-mods-10";
              memory = "12G";
              autoStart = false;
              whitelist = [
                "Xitonight"
                "Parcometro_"
                "BredBuryno"
                "KazimSen"
                "MineCherubLC"
                "Yukiry_"
                "Edonic005"
                "Jesoo____"
              ];
              allowFlight = true;
              aikarFlags = false;
              jvmXXOpts = [
                "-XX:+UseZGC"
                "-XX:+ZGenerational"
                "-XX:SoftMaxHeapSize=7G"
                "-XX:MaxDirectMemorySize=1G"
              ];
              extraEnv.MALLOC_ARENA_MAX = "2";
              extraMods = [
                "https://cdn.modrinth.com/data/QI59B2cO/versions/2KVucv5X/tgbridge-0.9.14-neoforge-1.21.jar"
              ];
              restartCalendar = "Sun *-*-* 05:00:00";
              viewDistance = 16;
              simulationDistance = 16;
              motd = "What is this?... diorite...";
              pauseWhenEmptySeconds = -1;
            };
            atm11 = {
              enable = false;
              slug = "all-the-mods-11";
              port = 25566;
            };
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

        networking.firewall = {
          allowedTCPPorts = [ 25565 ];
          interfaces = {
            tailscale0 = {
              allowedTCPPorts = [ 22 ];
              allowedUDPPorts = [ 25565 ];
            };
            eno1.allowedTCPPorts = [ 22 ];
            wlp2s0.allowedTCPPorts = [ 22 ];
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
