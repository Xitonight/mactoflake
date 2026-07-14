{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  mactoflake.boot = {
    loader = "grub";
    silent-boot = false;
  };

  mactoflake.input.kanata.enable = true;

  mactoflake.network.tailscale = {
    enable = true;
    enableSSH = true;
  };

  mactoflake.hyprland.monitors = [
    {
      output = "eDP-1";
      mode = "1920x1080@60";
      scale = 1;
    }
    {
      output = "HDMI-A-1";
      mode = "1920x1080@75";
      scale = 1;
      position = "-1920x0";
    }
  ];

  system.stateVersion = "26.05";
}
