{
  self,
  inputs,
  ...
}:

{
  flake.nixosConfigurations.vm = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
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
      { networking.hostName = "vm"; }
      { home-manager.users.${self.const.username} = { imports = self.homeImports; }; }
      {
        mactoflake = {
          boot.loader = "grub";
          input.kanata.enable = false;

          network.tailscale = {
            enable = true;
            enableSSH = true;
          };

          hyprland.monitors = [
            {
              output = "Virtual-1";
              mode = "1920x1080";
              scale = 1;
            }
          ];
        };

        # Lets QEMU do clean shutdown / guest commands.
        services.qemuGuest.enable = true;
      }
    ];
  };
}
