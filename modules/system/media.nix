{
  flake.nixosModules.media =
    {
      username,
      ...
    }:
    {
      users.groups.media.gid = 997;

      users.users = {
        jellyfin.extraGroups = [ "media" ];
        navidrome.extraGroups = [ "media" ];
        "${username}".extraGroups = [ "media" ];
      };

      systemd.tmpfiles.rules = [
        "d /srv/media 0775 ${username} media -"
        "d /srv/media/movies 0775 ${username} media -"
        "d /srv/media/tv 0775 ${username} media -"
        "d /srv/media/music 0775 ${username} media -"
      ];

      services.jellyfin.enable = true;

      systemd.services.jellyfin.environment.DOTNET_SYSTEM_NET_DISABLEIPV6 = "1";

      services.navidrome = {
        enable = true;
        settings = {
          Address = "0.0.0.0";
          Port = 4533;
          BaseUrl = "/navidrome";
          MusicFolder = "/srv/media/music";
        };
      };
    };
}
