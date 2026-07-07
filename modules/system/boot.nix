{ lib, config, ... }:

let
  cfg = config.mactoflake.boot;
in
{
  options.mactoflake.boot = {
    loader = lib.mkOption {
      type = lib.types.enum [
        "grub"
        "systemd-boot"
      ];
      default = "systemd-boot";
      description = "Which bootloader to use. Set per-host in hosts/<name>/default.nix.";
    };

    grub.efiInstallAsRemovable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Install GRUB to the fallback removable EFI path
        (\EFI\BOOT\BOOTX64.EFI) instead of relying on a boot entry in NVRAM.
        Useful on boards that wipe EFI variables on reboot. When enabled,
        canTouchEfiVariables is forced to false.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.loader == "grub") {
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = cfg.grub.efiInstallAsRemovable;
        devices = [ "nodev" ];
        device = "nodev";
        minegrub-theme = {
          enable = true;
          splash = "Flakes go brrr";
          background = "background_options/1.20 - [Trails & Tales].png";
          boot-options-count = 3;
        };
      };
    })

    (lib.mkIf (cfg.loader == "systemd-boot") {
      boot.loader.systemd-boot.enable = true;
    })

    {
      boot = {
        loader.efi.canTouchEfiVariables = !cfg.grub.efiInstallAsRemovable;
        consoleLogLevel = 0;
        kernelParams = [
          "quiet"
          "splash"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
        ];
        initrd.verbose = false;
        initrd.systemd.enable = true;
      };
    }
  ];
}
