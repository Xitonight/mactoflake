{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
    ../../modules/system/nvidia.nix
  ];

  mactoflake.boot = {
    loader = "grub";
    silent-boot = true;
    plymouth = true;
    grub.efiInstallAsRemovable = true;
  };

  mactoflake.git.signingKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHLE2wMLk6xKtPG8f5UYWWfUYqtx9j4naGQqvYdCA14o";

  mactoflake.input.kanata.enable = true;

  mactoflake.network.tailscale = {
    enable = true;
    enableSSH = true;
  };

  mactoflake.hyprland.monitors = [
    {
      output = "HDMI-A-2";
      mode = "2560x1440@144";
      scale = 1;
    }
    {
      output = "HDMI-A-1";
      mode = "1920x1080@60";
      position = "-1080x0";
      scale = 1;
      transform = 1;
    }
  ];

  mactoflake.containers.enable = true;

  system.stateVersion = "26.05";
}
