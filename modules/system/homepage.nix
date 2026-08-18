{
  flake.nixosModules.homepage = {
    services.homepage-dashboard = {
      enable = true;
      listenPort = 8082;
      openFirewall = true;
      allowedHosts = "mactoncino:8082,192.168.8.109:8082,localhost:8082,127.0.0.1:8082";

      settings = {
        title = "mactoncino";
        theme = "dark";
        color = "slate";
        headerStyle = "boxed";
        layout = {
          Media = {
            style = "row";
            columns = 3;
          };
        };
      };

      bookmarks = [
        {
          Developer = [
            {
              Github = [
                {
                  abbr = "GH";
                  href = "https://github.com/Xitonight/mactoflake";
                }
              ];
            }
          ];
        }
      ];

      services = [
        {
          Media = [
            {
              Jellyfin = {
                icon = "sh-jellyfin";
                href = "http://mactoncino:8096";
                description = "Movies & TV";
                siteMonitor = "http://localhost:8096";
              };
            }
            {
              Navidrome = {
                icon = "sh-navidrome";
                href = "http://mactoncino:4533";
                description = "Music";
                siteMonitor = "http://localhost:4533";
              };
            }
          ];
        }
      ];

      widgets = [
        {
          resources = {
            cpu = true;
            memory = true;
            disk = "/";
            uptime = true;
          };
        }
        {
          resources = {
            disk = "/srv/media";
          };
        }
        {
          search = {
            provider = "duckduckgo";
            target = "_blank";
          };
        }
      ];
    };
  };
}
