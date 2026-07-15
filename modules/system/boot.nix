{
  lib,
  config,
  ...
}:

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

    silent-boot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Silence kernel/initrd/console logging during boot.
        Adds kernelParams (quiet, splash, udev log suppression),
        sets consoleLogLevel to 0, and disables initrd verbosity.
      '';
    };

    plymouth = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Enable Plymouth boot splash with the Minecraft theme.
        Hides kernel boot logs behind a themed splash during the post-GRUB
        boot phase. Pairs best with silent-boot.
      '';
    };

    grub.efiInstallAsRemovable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Install GRUB to the fallback removable EFI path
        (\EFI\BOOT\BOOTX64.EFI) instead of relying on a boot entry in NVRAM.
        Useful on boards that wipe EFI variables on reboot. Only takes effect
        when loader is "grub"; when active, canTouchEfiVariables is forced to
        false. Safe to leave enabled when switching to systemd-boot.
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
        splashImage = lib.mkForce null;
        extraPerEntryConfig = ''
          echo "Loading Linux..."
          echo "Loading initial ramdisk..."
        '';
      };
    })

    (lib.mkIf (cfg.loader == "systemd-boot") {
      boot.loader.systemd-boot.enable = true;
    })

    {
      boot = {
        loader.efi.canTouchEfiVariables = !(cfg.grub.efiInstallAsRemovable && cfg.loader == "grub");
        initrd.systemd.enable = true;
        consoleLogLevel = lib.mkIf cfg.silent-boot 0;
        kernelParams = lib.mkIf cfg.silent-boot [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "loglevel=3"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
          "audit=0"
        ];
        initrd.verbose = lib.mkIf cfg.silent-boot false;
      };
    }

    (lib.mkIf cfg.plymouth {
      boot.plymouth = {
        enable = true;
        plymouth-minecraft-theme.enable = true;
      };
    })
  ];
}
