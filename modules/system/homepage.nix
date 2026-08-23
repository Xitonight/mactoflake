{
  flake.nixosModules.homepage =
    {
      config,
      username,
      ...
    }:
    {
      services.homepage-dashboard = {
        enable = true;
        listenPort = 8082;
        openFirewall = true;
        allowedHosts = "mactoncino:8082,mactoncino.taila7373f.ts.net,mactoncino.taila7373f.ts.net:8082";
        environmentFiles = [ config.sops.templates.homepage-env.path ];

        settings = {
          title = "mactoncino";
          theme = "dark";
          color = "slate";
          headerStyle = "boxed";
          iconStyle = "theme";
          hideVersion = true;
          layout = {
            Media = {
              style = "row";
              columns = 4;
            };
            Downloads = {
              style = "row";
              columns = 4;
            };
            Home = {
              style = "row";
              columns = 4;
            };
            Network = {
              style = "row";
              columns = 4;
            };
            Developer = {
              style = "row";
              columns = 4;
            };
            Admin = {
              style = "row";
              columns = 4;
            };
          };
        };

        widgets = [
          {
            search = {
              provider = "custom";
              url = "https://unduck.link?q=";
              focus = true;
              target = "_blank";
            };
          }
          {
            datetime = {
              text_size = "xl";
              format = {
                timeStyle = "short";
                hourCycle = "h23";
              };
            };
          }
          {
            openmeteo = {
              label = "Diano Borello";
              latitude = 43.9462811;
              longitude = 8.0490312;
              timezone = "Europe/Rome";
              units = "metric";
              cache = 5;
            };
          }
          {
            resources = {
              label = "mactoncino";
              cpu = true;
              memory = true;
              disk = "/";
              uptime = true;
            };
          }
        ];

        bookmarks = [
          {
            Developer = [
              {
                mactoflake = [
                  {
                    icon = "si-github";
                    href = "https://github.com/Xitonight/mactoflake";
                  }
                ];
              }
            ];
          }
          {
            Admin = [
              {
                Tailscale = [
                  {
                    icon = "tailscale.png";
                    href = "https://console.tailscale.com/admin/machines";
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
                  icon = "jellyfin.png";
                  href = "http://mactoncino:8096";
                  description = "Movies & TV";
                  widget = {
                    type = "jellyfin";
                    url = "http://mactoncino:8096";
                    key = "{{HOMEPAGE_VAR_JELLYFIN_API_KEY}}";
                    enableBlocks = true;
                  };
                };
              }
              {
                Navidrome = {
                  icon = "navidrome.png";
                  href = "http://mactoncino:4533/navidrome";
                  description = "Music";
                  widget = {
                    type = "navidrome";
                    url = "http://mactoncino:4533/navidrome";
                    user = "{{HOMEPAGE_VAR_NAVIDROME_USER}}";
                    token = "{{HOMEPAGE_VAR_NAVIDROME_TOKEN}}";
                    salt = "{{HOMEPAGE_VAR_NAVIDROME_SALT}}";
                  };
                };
              }
            ];
          }
          {
            Downloads = [
              {
                Sonarr = {
                  icon = "sonarr.png";
                  href = "http://mactoncino:8989";
                  description = "Series management";
                  widget = {
                    type = "sonarr";
                    url = "http://mactoncino:8989";
                    key = "{{HOMEPAGE_VAR_SONARR_API_KEY}}";
                  };
                };
              }
              {
                Radarr = {
                  icon = "radarr.png";
                  href = "http://mactoncino:7878";
                  description = "Movie management";
                  widget = {
                    type = "radarr";
                    url = "http://mactoncino:7878";
                    key = "{{HOMEPAGE_VAR_RADARR_API_KEY}}";
                  };
                };
              }
              {
                Prowlarr = {
                  icon = "prowlarr.png";
                  href = "http://mactoncino:9696";
                  description = "Indexer management";
                  widget = {
                    type = "prowlarr";
                    url = "http://mactoncino:9696";
                    key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
                  };
                };
              }
              {
                qBittorrent = {
                  icon = "qbittorrent.png";
                  href = "http://mactoncino:8081";
                  description = "Torrent client";
                  widget = {
                    type = "qbittorrent";
                    url = "http://mactoncino:8081";
                    inherit username;
                    password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
                  };
                };
              }
              {
                slskd = {
                  icon = "slskd.png";
                  href = "http://mactoncino:5030";
                  description = "Soulseek";
                  widget = {
                    type = "slskd";
                    url = "http://mactoncino:5030";
                    key = "{{HOMEPAGE_VAR_SLSKD_API_KEY}}";
                  };
                };
              }
              {
                DroppedNeedle = {
                  icon = "mdi-music-circle";
                  href = "http://mactoncino:8688";
                  description = "Music requests";
                  siteMonitor = "http://mactoncino:8688";
                };
              }
            ];
          }
          {
            Home = [
              {
                "Home Assistant" = {
                  icon = "home-assistant.png";
                  href = "http://mactoncino:8123";
                  description = "Home automation";
                  widget = {
                    type = "homeassistant";
                    url = "http://mactoncino:8123";
                    key = "{{HOMEPAGE_VAR_HASS_TOKEN}}";
                  };
                };
              }
              {
                n8n = {
                  icon = "n8n.png";
                  href = "http://mactoncino:5678";
                  description = "Workflow automation";
                  siteMonitor = "http://mactoncino:5678";
                };
              }
              {
                Paperless = {
                  icon = "paperless-ngx.png";
                  href = "http://mactoncino:28981/paperless";
                  description = "Document management";
                  widget = {
                    type = "paperlessngx";
                    url = "http://mactoncino:28981/paperless";
                    username = "admin";
                    password = "{{HOMEPAGE_VAR_PAPERLESS_PASSWORD}}";
                  };
                };
              }
            ];
          }
          {
            Network = [
              {
                "Pi-hole" = {
                  icon = "pi-hole.png";
                  href = "http://mactoncino:3000";
                  description = "DNS ad blocking";
                  widget = {
                    type = "pihole";
                    url = "http://mactoncino:3000";
                    version = 6;
                  };
                };
              }
              {
                Router = {
                  icon = "mdi-router-wireless";
                  href = "http://192.168.8.1";
                  description = "Mactofi gateway";
                  siteMonitor = "http://192.168.8.1";
                };
              }
            ];
          }
        ];

        customCSS = ''
          .service-card {
            border-radius: 0.65rem;
          }
          .service-card:hover {
            transform: translateY(-2px);
          }
        '';
      };

      sops.secrets = {
        homepage-jellyfin-api-key = {
          sopsFile = ../../secrets/homepage.yaml;
          key = "jellyfin-api-key";
        };
        homepage-hass-token = {
          sopsFile = ../../secrets/homepage.yaml;
          key = "hass-token";
        };
        homepage-pihole-password = {
          sopsFile = ../../secrets/homepage.yaml;
          key = "pihole-password";
        };
        homepage-navidrome-user = {
          sopsFile = ../../secrets/homepage.yaml;
          key = "navidrome-user";
        };
        homepage-navidrome-token = {
          sopsFile = ../../secrets/homepage.yaml;
          key = "navidrome-token";
        };
        homepage-navidrome-salt = {
          sopsFile = ../../secrets/homepage.yaml;
          key = "navidrome-salt";
        };
        homepage-sonarr-api-key = {
          sopsFile = ../../secrets/homepage.yaml;
          key = "sonarr-api-key";
        };
        homepage-radarr-api-key = {
          sopsFile = ../../secrets/homepage.yaml;
          key = "radarr-api-key";
        };
        homepage-prowlarr-api-key = {
          sopsFile = ../../secrets/homepage.yaml;
          key = "prowlarr-api-key";
        };
        homepage-qbittorrent-password = {
          sopsFile = ../../secrets/homepage.yaml;
          key = "qbittorrent-password";
        };
        homepage-slskd-api-key = {
          sopsFile = ../../secrets/slskd.yaml;
          key = "slskd-api-key";
        };
        homepage-paperless-password = {
          sopsFile = ../../secrets/paperless.yaml;
          key = "paperless-password";
        };
      };

      sops.templates.homepage-env = {
        restartUnits = [ "homepage-dashboard.service" ];
        content = ''
          HOMEPAGE_VAR_JELLYFIN_API_KEY=${config.sops.placeholder.homepage-jellyfin-api-key}
          HOMEPAGE_VAR_HASS_TOKEN=${config.sops.placeholder.homepage-hass-token}
          HOMEPAGE_VAR_PIHOLE_PASSWORD=${config.sops.placeholder.homepage-pihole-password}
          HOMEPAGE_VAR_NAVIDROME_USER=${config.sops.placeholder.homepage-navidrome-user}
          HOMEPAGE_VAR_NAVIDROME_TOKEN=${config.sops.placeholder.homepage-navidrome-token}
          HOMEPAGE_VAR_NAVIDROME_SALT=${config.sops.placeholder.homepage-navidrome-salt}
          HOMEPAGE_VAR_SONARR_API_KEY=${config.sops.placeholder.homepage-sonarr-api-key}
          HOMEPAGE_VAR_RADARR_API_KEY=${config.sops.placeholder.homepage-radarr-api-key}
          HOMEPAGE_VAR_PROWLARR_API_KEY=${config.sops.placeholder.homepage-prowlarr-api-key}
          HOMEPAGE_VAR_QBITTORRENT_PASSWORD=${config.sops.placeholder.homepage-qbittorrent-password}
          HOMEPAGE_VAR_SLSKD_API_KEY=${config.sops.placeholder.homepage-slskd-api-key}
          HOMEPAGE_VAR_PAPERLESS_PASSWORD=${config.sops.placeholder.homepage-paperless-password}
        '';
      };
    };
}
