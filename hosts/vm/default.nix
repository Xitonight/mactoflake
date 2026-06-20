{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "vm";

  users.users.xitonight = {
    isNormalUser = true;
    description = "Xitonight";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    initialPassword = "2110";
  };

  # Passwordless sudo on the wheel group — convenient for remote rebuilds on a throwaway VM.
  # Remove this on real hardware.
  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Lets QEMU do clean shutdown / guest commands.
  services.qemuGuest.enable = true;

  system.stateVersion = "26.05";
}
