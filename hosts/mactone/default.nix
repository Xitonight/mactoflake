{ config, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/system/nvidia.nix
  ];

  mactoflake.boot = {
    loader = "grub";
    grub.efiInstallAsRemovable = true;
  };

  mactoflake.input.kanata.enable = false;

  mactoflake.network.tailscale = {
    enable = true;
    enableSSH = true;
  };

  mactoflake.hyprland.monitors = [
    {
      output = "HDMI-A-1";
      mode = "1920x1080@75";
      scale = 1;
    }
  ];

  system.stateVersion = "26.05";
}
