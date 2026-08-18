{
  self,
  inputs,
  ...
}:

{
  flake.nixosConfigurations.mactone = inputs.nixpkgs.lib.nixosSystem {
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
      self.nixosModules.core
      self.nixosModules.home-manager
      self.nixosModules.nvidia
      {
        home-manager.users.${self.const.username} = {
          imports = self.homeImports;
        };
        networking.hostName = "mactone";

        mactoflake = {
          containers.enable = true;
          virtualization.enable = true;
          git.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHLE2wMLk6xKtPG8f5UYWWfUYqtx9j4naGQqvYdCA14o";
          input.kanata.enable = true;

          boot = {
            loader = "grub";
            silent-boot = true;
            plymouth = true;
            grub = {
              efiInstallAsRemovable = true;
              useOSProber = true;
            };
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

          hyprland.monitors = [
            {
              output = "HDMI-A-2";
              mode = "2560x1440@144";
              scale = 1;
            }
            {
              output = "HDMI-A-1";
              mode = "1920x1080@60";
              position = "-1080x0";
              scale = 1;
              transform = 1;
            }
          ];
        };
      }
    ];
  };
}
