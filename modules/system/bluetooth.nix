{ config, pkgs, ... }:
{
  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    package = pkgs.bluez;
    settings.General = {
      experimental = true; # show battery
      Privacy = "device";
      JustWorksRepairing = "always";
      Class = "0x000100";
      FastConnectable = true;
    };
  };
  environment.systemPackages = with pkgs; [ bluetui ];
}
