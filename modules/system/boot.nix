{ lib, config, ... }:

let cfg = config.flakey.boot;
in {
  options.flakey.boot.loader = lib.mkOption {
    type = lib.types.enum [ "grub" "systemd-boot" ];
    default = "systemd-boot";
    description = "Which bootloader to use. Set per-host in hosts/<name>/default.nix.";
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.loader == "grub") {
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        devices = [ "nodev" ];
        minegrub-theme = {
          enable = true;
          splash = "100% Flakes!";
          background = "background_options/1.20 - [Trails & Tales].png";
          boot-options-count = 4;
        };
      };
    })

    (lib.mkIf (cfg.loader == "systemd-boot") {
      boot.loader.systemd-boot.enable = true;
    })

    {
      boot = {
        loader.efi.canTouchEfiVariables = true;
        # consoleLogLevel = 0;
        # kernelParams = ["quiet" "rd.systemd.show_status=false" "rd.udev.log_level=3" "udev.log_priority=3"];
        # initrd.verbose = false;
        # initrd.systemd.enable = true;
      };
    }
  ];
}
