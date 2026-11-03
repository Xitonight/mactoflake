{
  flake.nixosModules.sdhci =
    { lib, config, ... }:
    let
      cfg = config.mactoflake.sdhci;
    in
    {
      options.mactoflake.sdhci = {
        enable = lib.mkEnableOption "O2 Micro / BayHub SD card reader support";

        disableAspm = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = ''
            Globally disable PCIe ASPM. Battery-costly fallback for readers
            that still fail detection with runtime PM excluded.
          '';
        };
      };

      config = lib.mkIf cfg.enable {
        boot = {
          kernelModules = [
            "mmc_core"
            "mmc_block"
            "sdhci"
            "sdhci_pci"
          ];
          kernelParams = lib.mkIf cfg.disableAspm [ "pcie_aspm=off" ];
        };

        services.tlp.settings = lib.mkIf config.services.tlp.enable {
          RUNTIME_PM_DENYLIST = "1217:8621";
        };
      };
    };
}
