{
  flake.nixosModules.pihole = {
    services.pihole-ftl = {
      enable = true;
      openFirewallDNS = true;
      openFirewallWebserver = true;

      lists = [
        {
          url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt";
          description = "HaGeZi blocklist";
        }
        {
          url = "https://raw.githubusercontent.com/easylist/easylist/master/easyprivacy/easyprivacy_thirdparty_international.txt";
          description = "Italian blocklist";
        }
      ];

      settings = {
        dns = {
          upstreams = [
            "8.8.8.8"
            "8.8.4.4"
          ];
        };
      };
    };

    services.pihole-web = {
      enable = true;
      ports = [ 3000 ];
    };
  };
}
