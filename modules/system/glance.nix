{
  flake.nixosModules.glance = {
    services.glance = {
      enable = true;
      openFirewall = true;
      settings = {
        server = {
          host = "0.0.0.0";
          port = 8080;
        };

        branding = {
          app-name = "mactoncino";
        };

        pages = [
          {
            name = "Home";
            columns = [
              {
                size = "small";
                widgets = [
                  {
                    type = "clock";
                    hour-format = "24h";
                  }
                  {
                    type = "weather";
                    location = "Diano Borello, Italy";
                    units = "metric";
                    hour-format = "24h";
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        title = "Network";
                        links = [
                          {
                            title = "Router";
                            url = "http://192.168.8.1";
                            icon = "mdi:router-wireless";
                          }
                          {
                            title = "Tailscale";
                            url = "https://console.tailscale.com/admin/machines";
                            icon = "si:tailscale";
                          }
                        ];
                      }
                      {
                        title = "Developer";
                        links = [
                          {
                            title = "mactoflake";
                            url = "https://github.com/Xitonight/mactoflake";
                            icon = "si:github";
                          }
                        ];
                      }
                    ];
                  }
                ];
              }
              {
                size = "full";
                widgets = [
                  {
                    type = "search";
                    search-engine = "https://unduck.link?q={QUERY}";
                    new-tab = true;
                    autofocus = true;
                  }
                  {
                    type = "monitor";
                    title = "Services";
                    sites = [
                      {
                        title = "Jellyfin";
                        url = "http://mactoncino:8096";
                        icon = "sh:jellyfin";
                      }
                      {
                        title = "Navidrome";
                        url = "http://mactoncino:4533";
                        icon = "sh:navidrome";
                      }
                      {
                        title = "Pi-hole";
                        url = "http://mactoncino:3000";
                        icon = "sh:pi-hole";
                      }
                      {
                        title = "Home Assistant";
                        url = "http://mactoncino:8123";
                        icon = "sh:home-assistant";
                      }
                      {
                        title = "Paperless";
                        url = "http://mactoncino:28981";
                        icon = "mdi:file-document-outline";
                      }
                      {
                        title = "n8n";
                        url = "http://mactoncino:5678";
                        icon = "si:n8n";
                      }
                      {
                        title = "Sonarr";
                        url = "http://mactoncino:8989";
                        icon = "di:sonarr";
                      }
                      {
                        title = "Radarr";
                        url = "http://mactoncino:7878";
                        icon = "di:radarr";
                      }
                      {
                        title = "Prowlarr";
                        url = "http://mactoncino:9696";
                        icon = "di:prowlarr";
                      }
                      {
                        title = "qBittorrent";
                        url = "http://mactoncino:8081";
                        icon = "sh:qbittorrent";
                        alt-status-codes = [
                          401
                          403
                        ];
                      }
                      {
                        title = "Router";
                        url = "http://192.168.8.1";
                        icon = "mdi:router-wireless";
                        alt-status-codes = [
                          401
                          403
                        ];
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
    };
  };
}
