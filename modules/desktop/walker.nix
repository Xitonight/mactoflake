{
  flake.homeModules.walker =
    {
      pkgs,
      lib,
      osConfig,
      ...
    }:
    let
      agent = if osConfig == null then "1password" else osConfig.mactoflake.ssh.agent;

      toml = pkgs.formats.toml { };
    in
    {
      home.packages = [
        pkgs.walker
        pkgs.elephant
      ];

      systemd.user.services = {
        elephant = {
          Unit = {
            Description = "Elephant data provider daemon for walker";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.elephant}/bin/elephant";
            Restart = "on-failure";
            RestartSec = "1s";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };

        walker = {
          Unit = {
            Description = "Walker launcher preload service";
            PartOf = [ "graphical-session.target" ];
            After = [
              "graphical-session.target"
              "elephant.service"
            ];
          };
          Service = {
            ExecStart = "${pkgs.walker}/bin/walker --gapplication-service";
            Restart = "on-failure";
            RestartSec = "1s";
          };
          Install.WantedBy = [ "graphical-session.target" ];
        };
      };

      xdg.configFile = {
        "walker/config.toml".source = toml.generate "walker-config.toml" (
          {
            theme = "matugen";
          }
          // lib.optionalAttrs (agent == "rbw") {
            providers.prefixes = [
              {
                prefix = "rbw ";
                provider = "bitwarden";
              }
            ];
          }
        );

        "elephant/bitwarden.toml".source = lib.mkIf (agent == "rbw") (
          toml.generate "bitwarden.toml" {
            autotype_support = true;
          }
        );
      };
    };
}
