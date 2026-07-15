{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  mactoflake.boot = {
    loader = "grub";
    silent-boot = true;
    plymouth = true;
  };

  mactoflake.virtualization.enable = true;

  mactoflake.git.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOx7KW5d4Xtx3fvBDCSeBylB5hTPYIzMB/ss7qJwva/ mactopad";

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
      position = "-1920x0";
    }
    {
      output = "HDMI-A-1";
      mode = "1920x1080@75";
      scale = 1;
      position = "0x0";
    }
    {
      output = "DP-1";
      mode = "1920x1080@75";
      scale = 1;
      position = "1920x0";
    }
  ];

  system.stateVersion = "26.05";
}
