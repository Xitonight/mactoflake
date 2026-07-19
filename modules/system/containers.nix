{
  lib,
  config,
  pkgs,
  username,
  ...
}:

let
  cfg = config.mactoflake.containers;
in
{
  options.mactoflake.containers = {
    enable = lib.mkEnableOption "Docker container runtime with compose";

    rootless = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Run Docker rootless so the daemon runs under the user account,
        avoiding the privileged docker socket and setuid docker-rootlessproxy.
      '';
    };

    enableOnBoot = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Start the Docker daemon automatically at boot. Disable to start it
        manually (e.g. on laptops to save battery).
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = !cfg.rootless;
      enableOnBoot = cfg.enableOnBoot;

      rootless = {
        enable = cfg.rootless;
        setSocketVariable = cfg.rootless;
      };

      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };

    environment.systemPackages = with pkgs; [
      docker-compose
      dive
    ];

    users.users."${username}".extraGroups =
      lib.mkIf (!cfg.rootless) [ "docker" ];
  };
}
