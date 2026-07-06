{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/system/nvidia.nix
  ];

  mactoflake.boot.loader = "grub";

  mactoflake.input.kanata.enable = false;

  mactoflake.network.tailscale = {
    enable = true;
    enableSSH = true;
  };

  mactoflake.hyprland.monitors = [
    {
      output = "HDMI-A-1";
      mode = "1920x1080@50";
      scale = 1;
    }
  ];

  users.users.xitonight = {
    isNormalUser = true;
    description = "Xitonight";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    initialPassword = "1234";
  };

  security.sudo.wheelNeedsPassword = false;

  services.getty.autologinUser = "xitonight";

  system.stateVersion = "26.05";
}
