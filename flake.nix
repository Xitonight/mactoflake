{
  description = "Xitonight's NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    minegrub-theme.url = "github:Lxtharia/minegrub-theme";
    hyprland.url = "github:hyprwm/Hyprland";

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        inputs.hjem.nixosModules.default
        ./hosts/vm
        ./modules/system
        inputs.minegrub-theme.nixosModules.default
      ];
    };
  };
}
