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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      flakeDir = "/etc/nixos";

      mkHost = hostName: {
        ${hostName} = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs flakeDir;
          };
          modules = [
            { networking.hostName = "${hostName}"; }
            ./hosts/${hostName}
            ./modules/system
            inputs.minegrub-theme.nixosModules.default

            home-manager.nixosModules.home-manager
            (
              { config, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit inputs flakeDir;
                    monitorsConfig = config.mactoflake.hyprland.monitors;
                  };
                  users.xitonight = import ./modules/home;
                };
              }
            )
          ];
        };
      };
    in
    {
      nixosConfigurations = (mkHost "vm") // (mkHost "mactopad");
    };
}
