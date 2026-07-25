{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  mactoflake = {
    containers.enable = true;
    virtualization.enable = true;
    git.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILI2oLqyj5ZEhObKpgxHDy+5ME7KOf9EpF9wA/ZUNI+R";
    input.kanata.enable = true;
    power.enable = true;

    boot = {
      loader = "grub";
      silent-boot = true;
      plymouth = true;
    };

    network = {
      openvpn = {
        enable = true;
        servers.work.configFile = "/etc/openvpn/work.ovpn";
      };
      tailscale = {
        enable = true;
        enableSSH = true;
      };
    };

    hyprland.monitors = [
      {
        output = "eDP-1";
        mode = "1920x1080@60";
        scale = 1;
        position = "-1920x0";
      }
      {
        output = "DP-1";
        mode = "1920x1080@75";
        scale = 1;
        position = "0x0";
      }
      {
        output = "HDMI-A-1";
        mode = "1920x1080@75";
        scale = 1;
        position = "1920x0";
      }
    ];
  };

  programs.kdeconnect.enable = true;

  system.stateVersion = "26.05";
}
