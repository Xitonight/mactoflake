{
  flake.nixosModules.media =
    {
      username,
      ...
    }:
    {
      users.groups.media = { };

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

      services.jellyfin = {
        enable = true;
        openFirewall = true;
      };

      services.navidrome = {
        enable = true;
        openFirewall = true;
        settings = {
          Address = "0.0.0.0";
          Port = 4533;
          MusicFolder = "/srv/media/music";
        };
      };
    };
}
