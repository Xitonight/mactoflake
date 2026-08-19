{
  flake.nixosModules.pihole = {
    services.pihole-ftl = {
      enable = true;
      openFirewallDNS = true;
      openFirewallWebserver = true;

      lists = [
        {
          url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
          description = "StevenBlack unified adlist";
        }
      ];

      settings = {
        dns = {
          upstreams = [
            "9.9.9.9"
            "149.112.112.112"
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
