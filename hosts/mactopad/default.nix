{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "mactopad";

  flakey.boot.loader = "grub";

  flakey.input.kanata.enable = true;

  flakey.hyprland.monitors = [{
    output = "eDP-1";
    mode = "1920x1080@60";
    scale = 1.33;
  }];

  users.users.xitonight = {
    isNormalUser = true;
    description = "Xitonight";
    extraGroups = [ "wheel" "networkmanager" ];
    initialPassword = "1234";
  };

  security.sudo.wheelNeedsPassword = false;

  services.getty.autologinUser = "xitonight";

  environment.systemPackages = with pkgs; [ vim git ];

  system.stateVersion = "26.05";
}
