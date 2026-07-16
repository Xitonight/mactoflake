{ lib, config, ... }:

let
  cfg = config.mactoflake.power;
in
{
  options.mactoflake.power = {
    enable = lib.mkEnableOption "TLP power and battery management";

    chargeThresholds = lib.mkOption {
      type = lib.types.submodule {
        options = {
          start = lib.mkOption {
            type = lib.types.nullOr (lib.types.ints.between 0 100);
            default = null;
            description = ''
              Battery charge level (%) at which charging resumes.
              Only effective on supported hardware (mainly ThinkPads).
            '';
          };
          stop = lib.mkOption {
            type = lib.types.nullOr (lib.types.ints.between 0 100);
            default = null;
            description = ''
              Battery charge level (%) at which charging stops.
              Only effective on supported hardware (mainly ThinkPads).
            '';
          };
        };
      };
      default = { };
      description = ''
        Battery charge thresholds for long-term battery health, e.g.
        start = 75, stop = 80. Silently ignored on unsupported hardware.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0 = lib.mkIf (cfg.chargeThresholds.start != null) cfg.chargeThresholds.start;
        STOP_CHARGE_THRESH_BAT0 = lib.mkIf (cfg.chargeThresholds.stop != null) cfg.chargeThresholds.stop;
      };
    };
  };
}
