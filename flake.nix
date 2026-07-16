{
  description = "Xitonight's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    minegrub-theme.url = "github:Lxtharia/minegrub-theme";
    minecraft-plymouth-theme.url = "github:nikp123/minecraft-plymouth-theme";
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
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      username = "xitonight";
      flakeDir = "/home/${username}/.mactoflake";
      papersDir = "$XDG_PICTURES_DIR/papers";
      email = "xitonight@gmail.com";

      mkHost = hostName: {
        ${hostName} = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit
              inputs
              flakeDir
              papersDir
              username
              email
              ;
          };
          modules = [
            {
              networking.hostName = "${hostName}";
              users.users."${username}" = {
                isNormalUser = true;
                extraGroups = [
                  "wheel"
                  "networkmanager"
                ];
                initialPassword = "1234";
              };
              security.sudo.wheelNeedsPassword = false;
              services.greetd = {
                enable = true;
                settings = rec {
                  initial_session = {
                    command = "uwsm start hyprland.desktop >/dev/null 2>&1";
                    user = "${username}";
                  };
                  default_session = initial_session;
                };
              };
            }
            ./hosts/${hostName}
            inputs.minegrub-theme.nixosModules.default
            inputs.minecraft-plymouth-theme.nixosModules.plymouth-minecraft-theme
            inputs.nix-index-database.nixosModules.nix-index

            home-manager.nixosModules.home-manager
            (
              { config, ... }:
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit
                      inputs
                      flakeDir
                      papersDir
                      username
                      email
                      ;
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
