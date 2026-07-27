{
  self,
  inputs,
  ...
}:

{
  flake.nixosModules.core =
    {
      username,
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
        self.nixosModules.shell
        self.nixosModules.tailscale
        self.nixosModules.udev
        self.nixosModules.virtualization

        inputs.minegrub-theme.nixosModules.default
        inputs.minecraft-plymouth-theme.nixosModules.plymouth-minecraft-theme
        inputs.nix-index-database.nixosModules.nix-index
      ];

      users.users."${username}" = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
        initialPassword = "1234";
      };

      security.sudo.wheelNeedsPassword = false;

      services.greetd = {
        enable = true;
        settings = rec {
          initial_session = {
            command = "uwsm start hyprland.desktop >/dev/null 2>&1";
            user = "${username}";
          };
          default_session = initial_session;
        };
      };

      system.stateVersion = "26.05";
    };
}
