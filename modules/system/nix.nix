{ inputs, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    trusted-users = [
      "root"
      "xitonight"
    ];
  };

  # Pin `nixpkgs` used by ad-hoc `nix run nixpkgs#...` / `nix shell nixpkgs#...`
  # to the same revision as the flake.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nixpkgs.config.allowUnfree = true;
}
