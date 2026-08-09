{
  self,
  inputs,
  ...
}:

{
  flake.nixosModules.core =
    {
      username,
      config,
      ...
    }:
    {
      imports = [
        self.nixosModules.audio
        self.nixosModules.bluetooth
        self.nixosModules.boot
        self.nixosModules.cachix
        self.nixosModules.containers
        self.nixosModules.fonts
        self.nixosModules.git
        self.nixosModules.greetd
        self.nixosModules.hyprland
        self.nixosModules.kanata
        self.nixosModules.locale
        self.nixosModules.network
        self.nixosModules.nh
        self.nixosModules.nix
        self.nixosModules.onepassword
        self.nixosModules.openvpn
        self.nixosModules.overlays
        self.nixosModules.packages
        self.nixosModules.polkit
        self.nixosModules.power
        self.nixosModules.quickshare
        self.nixosModules.shell
        self.nixosModules.sops
        self.nixosModules.sudo
        self.nixosModules.tailscale
        self.nixosModules.udev
        self.nixosModules.virtualization
        self.nixosModules.steam

        inputs.minegrub-theme.nixosModules.default
        inputs.minecraft-plymouth-theme.nixosModules.plymouth-minecraft-theme
        inputs.nix-index-database.nixosModules.nix-index
      ];

      users.mutableUsers = false;

      users.users."${username}" = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        hashedPasswordFile = config.sops.secrets.xitonight-password.path;
      };

      system.stateVersion = "26.05";
    };
}
