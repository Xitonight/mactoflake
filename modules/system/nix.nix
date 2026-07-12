{ inputs, username, ... }:

{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    trusted-users = [
      "root"
      "${username}"
    ];
  };

  # Pin `nixpkgs` used by ad-hoc `nix run nixpkgs#...` / `nix shell nixpkgs#...`
  # to the same revision as the flake.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  nixpkgs.config = {
    allowUnfree = true;
    # obsidian bundles an EOL Electron runtime flagged insecure by nixpkgs.
    permittedInsecurePackages = [ "electron-39.8.10" ];
  };
}
