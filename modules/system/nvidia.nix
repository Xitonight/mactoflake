{
  config,
  pkgs,
  lib,
  ...
}:

let
  package = config.boot.kernelPackages.nvidiaPackages.latest;
in
{
  boot = {
    kernelParams = [
      "nvidia-drm.fbdev=1"
      "nvidia.NVreg_UsePageAttributeTable=1"
      "nvidia_modeset.disable_vrr_memclk_switch=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
    ];
    blacklistedKernelModules = [ "nouveau" ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    nvidia = {
      modesetting.enable = true;
      open = true;
      gsp.enable = config.hardware.nvidia.open;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      nvidiaSettings = false;
      package = config.boot.kernelPackages.nvidiaPackages.latest;
    };
  };

  environment = {
    sessionVariables = {
      "__GLX_VENDOR_LIBRARY_NAME" = "nvidia";
      "GBM_BACKEND" = "nvidia-drm";
    };
  };
}
