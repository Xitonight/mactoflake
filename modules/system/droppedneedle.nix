{
  flake.nixosModules.droppedneedle =
    {
      config,
      ...
    }:
    {
      users.groups.media = { };

      users.users.droppedneedle = {
        isSystemUser = true;
        group = "media";
        uid = 984;
      };

      systemd.tmpfiles.rules = [
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
          unitConfig.RequiresMountsFor = [ "/srv/media/music" ];
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
    };
}
