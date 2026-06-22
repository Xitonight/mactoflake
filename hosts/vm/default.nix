{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "vm";

  users.users.xitonight = {
    isNormalUser = true;
    description = "Xitonight";
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "2110";
  };

  security.sudo.wheelNeedsPassword = false;

  services.getty.autologinUser = "xitonight";

  environment.systemPackages = with pkgs; [ vim git ];

  # Lets QEMU do clean shutdown / guest commands.
  services.qemuGuest.enable = true;

  system.stateVersion = "26.05";
}
