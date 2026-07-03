{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.flakey.input.kanata;
in
{
  options.flakey.input.kanata = {
    enable = lib.mkEnableOption "kanata keyboard remapper with home-row mods";
  };

  config = lib.mkIf cfg.enable {
    hardware.uinput.enable = true;

    users.users.xitonight.extraGroups = [ "input" ];

    environment.etc."kanata/kanata.kbd".source = ./kanata.kbd;

    systemd.services.kanata = {
      description = "Kanata keyboard remapper";
      after = [ "dev-uinput.device" ];
      before = [ "graphical-session.target" ];
      wantedBy = [ "default.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.kanata}/bin/kanata --cfg /etc/kanata/kanata.kbd";
        Restart = "no";
        Nice = -20;
      };
    };
  };
}
