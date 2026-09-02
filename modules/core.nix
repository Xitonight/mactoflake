{
  self,
  inputs,
  ...
}:

{
  flake.nixosModules.core = {
    imports = [
      self.nixosModules.base

      self.nixosModules.audio
      self.nixosModules.bitwarden
      self.nixosModules.bluetooth
      self.nixosModules.containers
      self.nixosModules.fonts
      self.nixosModules.greetd
      self.nixosModules.hyprland
      self.nixosModules.kanata
      self.nixosModules.onepassword
      self.nixosModules.openvpn
      self.nixosModules.packages
      self.nixosModules.polkit
      self.nixosModules.power
      self.nixosModules.quickshare
      self.nixosModules.steam
      self.nixosModules.udev
      self.nixosModules.virtualization
    ];
  };
}
