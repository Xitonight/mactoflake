{
  flake.nixosModules.droppedneedle =
    {
      lib,
      config,
      username,
      ...
    }:
    {
      users.groups.media = { };

      users.users.droppedneedle = {
        isSystemUser = true;
        group = "media";
        uid = 995;
      };

      systemd.tmpfiles.rules = [
        "d /srv/media/music-requests 0775 ${username} media -"
        "d /srv/droppedneedle 0750 droppedneedle media -"
        "d /srv/droppedneedle/config 0750 droppedneedle media -"
        "d /srv/droppedneedle/cache 0750 droppedneedle media -"
        "d /srv/droppedneedle/plugins 0750 droppedneedle media -"
      ];

      assertions = [
        {
          assertion = config.virtualisation.docker.enable;
          message = "droppedneedle requires the docker daemon (enable mactoflake.containers with rootless = false).";
        }
        {
          assertion = config.services.navidrome.enable;
          message = "droppedneedle expects services.navidrome (import nixosModules.media) for the music library.";
        }
        {
          assertion = config.services.slskd.enable;
          message = "droppedneedle expects services.slskd (import nixosModules.slskd) as its download client.";
        }
      ];

      virtualisation.oci-containers.backend = "docker";

      systemd.services = {
        navidrome = {
          unitConfig.RequiresMountsFor = [
            "/srv/media/music"
            "/srv/media/music-requests"
          ];
          serviceConfig.BindReadOnlyPaths = [ "/srv/media/music-requests" ];
        };

        docker.unitConfig.RequiresMountsFor = [ "/srv/media" ];
      };

      virtualisation.oci-containers.containers.droppedneedle = {
        image = "droppedneedle/droppedneedle:latest";
        autoStart = true;

        environment = {
          PUID = toString config.users.users.droppedneedle.uid;
          PGID = toString config.users.groups.media.gid;
          UMASK = "002";
          TZ = config.time.timeZone;
          PORT = "8688";
          SLSKD_DOWNLOADS_PATH = "/data/downloads/soulseek";
        };

        volumes = [
          "/srv/droppedneedle/config:/app/config"
          "/srv/droppedneedle/cache:/app/cache"
          "/srv/droppedneedle/plugins:/app/plugins"
          "/srv/media:/data"
        ];

        extraOptions = [ "--network=host" ];
      };

      services.homepage-dashboard = lib.mkIf config.services.homepage-dashboard.enable {
        services = [
          {
            Media = [
              {
                DroppedNeedle = {
                  icon = "mdi-music-note-plus";
                  href = "http://mactoncino:8688";
                  description = "Music requests";
                  siteMonitor = "http://mactoncino:8688/health";
                };
              }
            ];
          }
        ];
      };
    };
}
