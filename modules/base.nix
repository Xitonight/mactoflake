{
  self,
  inputs,
  ...
}:

{
  flake.nixosModules.base =
    {
      username,
      config,
      ...
    }:

    {
      imports = [
        self.nixosModules.boot
        self.nixosModules.cachix
        self.nixosModules.git
        self.nixosModules.locale
        self.nixosModules.network
        self.nixosModules.nh
        self.nixosModules.nix
        self.nixosModules.overlays
        self.nixosModules.shell
        self.nixosModules.sops
        self.nixosModules.ssh
        self.nixosModules.sudo
        self.nixosModules.tailscale
        self.nixosModules.wifi

        inputs.minegrub-theme.nixosModules.default
        inputs.minecraft-plymouth-theme.nixosModules.plymouth-minecraft-theme
        inputs.nix-index-database.nixosModules.nix-index
      ];

      users.mutableUsers = false;

      users.users."${username}" = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.xitonight-password.path;
      };

      system.stateVersion = "26.05";
    };
}
