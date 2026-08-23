{
  flake.nixosModules.droppedneedle =
    {
      config,
      lib,
      username,
      ...
    }:
    {
      users.groups.media = { };

      systemd.tmpfiles.rules = [
        "d /var/lib/droppedneedle 0775 ${username} media -"
        "d /var/lib/droppedneedle/config 0775 ${username} media -"
        "d /var/lib/droppedneedle/cache 0775 ${username} media -"
        "d /var/lib/droppedneedle/plugins 0775 ${username} media -"
      ];

      virtualisation = {
        docker = {
          enable = true;
          autoPrune = {
            enable = true;
            dates = "weekly";
            flags = [ "--all" ];
          };
        };

        oci-containers = {
          backend = "docker";

          containers.droppedneedle = {
            image = "droppedneedle/droppedneedle:latest@sha256:fbd99ca78577c9da599abd2cff72025ee52b2e163dd632402d279430d8536cef";
            ports = [ "8688:8688" ];
            environment = {
              PUID = "1000";
              PGID = "997";
              UMASK = "002";
              PORT = "8688";
              TZ = "Europe/Rome";
              SLSKD_DOWNLOADS_PATH = "/data/downloads/soulseek";
            };
            volumes = [
              "/var/lib/droppedneedle/config:/app/config"
              "/var/lib/droppedneedle/cache:/app/cache"
              "/var/lib/droppedneedle/plugins:/app/plugins"
              "/srv/media:/data"
            ];
            extraOptions = [ "--add-host=host.docker.internal:host-gateway" ];
          };
        };
      };

      networking.firewall.allowedTCPPorts = [ 8688 ];
    };
}
