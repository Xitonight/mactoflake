{
  flake.nixosModules.arr =
    {
      username,
      ...
    }:
    {
      users.groups.media = { };

      systemd.tmpfiles.rules = [
        "d /srv/media/downloads 0775 ${username} media -"
      ];

      services = {
        sonarr = {
          enable = true;
          openFirewall = true;
          group = "media";
        };

        radarr = {
          enable = true;
          openFirewall = true;
          group = "media";
        };

        prowlarr = {
          enable = true;
          openFirewall = true;
        };

        flaresolverr.enable = true;

        qbittorrent = {
          enable = true;
          openFirewall = true;
          group = "media";
          webuiPort = 8081;
          torrentingPort = 6881;
          extraArgs = [ "--confirm-legal-notice" ];
          serverConfig.BitTorrent.Session.DefaultSavePath = "/srv/media/downloads";
        };
      };
    };
}
