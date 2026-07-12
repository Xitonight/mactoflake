{
  description = "Xitonight's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    minegrub-theme.url = "github:Lxtharia/minegrub-theme";
    hyprland.url = "github:hyprwm/Hyprland";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      username = "xitonight";
      flakeDir = "/home/${username}/.mactoflake";

      mkHost = hostName: {
        ${hostName} = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs flakeDir username;
          };
          modules = [
            {
              networking.hostName = "${hostName}";
              users.users."${username}" = {
                isNormalUser = true;
                description = "Xitonight";
                extraGroups = [
                  "wheel"
                  "networkmanager"
                ];
                initialPassword = "1234";
              };
              security.sudo.wheelNeedsPassword = false;
              services.getty.autologinUser = "${username}";
            }
            ./hosts/${hostName}
            inputs.minegrub-theme.nixosModules.default
            inputs.nix-index-database.nixosModules.nix-index

            home-manager.nixosModules.home-manager
            (
              { config, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit inputs flakeDir username;
                    monitorsConfig = config.mactoflake.hyprland.monitors;
                  };
                  users."${username}" = import ./modules/home;
                };
              }
            )
          ];
        };
      };
    in
    {
      nixosConfigurations = (mkHost "vm") // (mkHost "mactopad") // (mkHost "mactone");
    };
}
