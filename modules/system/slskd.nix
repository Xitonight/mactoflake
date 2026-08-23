{
  flake.nixosModules.slskd =
    {
      config,
      username,
      ...
    }:
    {
      users.groups.media = { };

      systemd.tmpfiles.rules = [
        "d /srv/media/downloads/soulseek 0775 ${username} media -"
        "d /srv/media/downloads/soulseek-incomplete 0775 ${username} media -"
      ];

      services.slskd = {
        enable = true;
        group = "media";
        openFirewall = true;
        environmentFile = config.sops.templates.slskd-env.path;
        settings = {
          directories = {
            downloads = "/srv/media/downloads/soulseek";
            incomplete = "/srv/media/downloads/soulseek-incomplete";
          };
          shares.directories = [ "/srv/media/music" ];
        };
      };

      systemd.services.slskd.serviceConfig.UMask = "0002";

      sops.secrets = {
        slskd-web-username = {
          sopsFile = ../../secrets/slskd.yaml;
          key = "web-username";
        };
        slskd-web-password = {
          sopsFile = ../../secrets/slskd.yaml;
          key = "web-password";
        };
        slskd-slsk-username = {
          sopsFile = ../../secrets/slskd.yaml;
          key = "slsk-username";
        };
        slskd-slsk-password = {
          sopsFile = ../../secrets/slskd.yaml;
          key = "slsk-password";
        };
        slskd-jwt-key = {
          sopsFile = ../../secrets/slskd.yaml;
          key = "jwt-key";
        };
        slskd-api-key = {
          sopsFile = ../../secrets/slskd.yaml;
          key = "slskd-api-key";
        };
      };

      sops.templates.slskd-env = {
        owner = "slskd";
        restartUnits = [ "slskd.service" ];
        content = ''
          SLSKD_USERNAME=${config.sops.placeholder.slskd-web-username}
          SLSKD_PASSWORD=${config.sops.placeholder.slskd-web-password}
          SLSKD_SLSK_USERNAME=${config.sops.placeholder.slskd-slsk-username}
          SLSKD_SLSK_PASSWORD=${config.sops.placeholder.slskd-slsk-password}
          SLSKD_JWT_KEY=${config.sops.placeholder.slskd-jwt-key}
          SLSKD_API_KEY=${config.sops.placeholder.slskd-api-key}
        '';
      };

      networking.firewall.allowedTCPPorts = [ 5030 ];
    };
}
