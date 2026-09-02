{
  flake.nixosModules.bitwarden =
    {
      lib,
      pkgs,
      config,
      ...
    }:
    {
      config = lib.mkIf (config.mactoflake.ssh.agent == "bitwarden") {
        environment.systemPackages = [ pkgs.bitwarden-desktop ];
      };
    };
}
