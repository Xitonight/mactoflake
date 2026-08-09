{
  flake.nixosModules.boot =
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

        grub = {
          useOSProber = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Enable the grub OS prober to find other system entries automatically.
            '';
          };
          efiInstallAsRemovable = lib.mkOption {
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
      };

      config = lib.mkMerge [
        (lib.mkIf (cfg.loader == "grub") {
          boot.loader.grub = {
            enable = true;
            efiSupport = true;
            efiInstallAsRemovable = cfg.grub.efiInstallAsRemovable;
            devices = [ "nodev" ];
            device = "nodev";
            useOSProber = cfg.grub.useOSProber;
            minegrub-theme = {
              enable = true;
              splash = "Flakes go brrr";
              background = "background_options/1.20 - [Trails & Tales].png";
              boot-options-count = 3;
            };
            splashImage = lib.mkForce null;
            extraPerEntryConfig = ''
              echo ""
              echo "          ▗▄▄▄       ▗▄▄▄▄    ▄▄▄▖             "
              echo "          ▜███▙       ▜███▙  ▟███▛             "
              echo "           ▜███▙       ▜███▙▟███▛              "
              echo "            ▜███▙       ▜██████▛               "
              echo "     ▟█████████████████▙ ▜████▛     ▟▙         "
              echo "    ▟███████████████████▙ ▜███▙    ▟██▙        "
              echo "           ▄▄▄▄▖           ▜███▙  ▟███▛        "
              echo "          ▟███▛             ▜██▛ ▟███▛         "
              echo "         ▟███▛               ▜▛ ▟███▛          "
              echo "▟███████████▛                  ▟██████████▙    "
              echo "▜██████████▛                  ▟███████████▛    "
              echo "      ▟███▛ ▟▙               ▟███▛             "
              echo "     ▟███▛ ▟██▙             ▟███▛              "
              echo "    ▟███▛  ▜███▙           ▝▀▀▀▀               "
              echo "    ▜██▛    ▜███▙ ▜██████████████████▛         "
              echo "     ▜▛     ▟████▙ ▜████████████████▛          "
              echo "           ▟██████▙         ▜███▙              "
              echo "          ▟███▛▜███▙         ▜███▙             "
              echo "         ▟███▛  ▜███▙         ▜███▙            "
              echo "         ▝▀▀▀    ▀▀▀▀▘         ▀▀▀▘            "
              echo ""
              echo "Loading the corn flakes..."
              echo "Watching the snow flakes falling..."
              echo "Chipping the obsidian flakes..."
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

        {
          security.auditd.enable = true;

          boot.kernel.sysctl = {
            "kernel.kptr_restrict" = 2;
            "kernel.dmesg_restrict" = 1;
            "kernel.unprivileged_bpf_disabled" = 1;
            "kernel.yama.ptrace_scope" = 2;
            "dev.tty.ldisc_autoload" = 0;
            "net.ipv4.tcp_syncookies" = 1;
            "net.ipv4.conf.all.rp_filter" = 1;
            "net.ipv4.conf.default.rp_filter" = 1;
            "net.ipv4.conf.all.accept_redirects" = 0;
            "net.ipv4.conf.default.accept_redirects" = 0;
            "net.ipv4.conf.all.send_redirects" = 0;
            "net.ipv6.conf.all.accept_redirects" = 0;
            "net.ipv6.conf.default.accept_redirects" = 0;
          };
        }
      ];
    };
}
