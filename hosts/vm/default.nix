{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../modules/system
  ];

  mactoflake.boot.loader = "grub";

  mactoflake.input.kanata.enable = false;

  mactoflake.network.tailscale = {
    enable = true;
    enableSSH = true;
  };

  mactoflake.hyprland.monitors = [
    {
      output = "Virtual-1";
      mode = "1920x1080";
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

  # Lets QEMU do clean shutdown / guest commands.
  services.qemuGuest.enable = true;

  system.stateVersion = "26.05";
}
