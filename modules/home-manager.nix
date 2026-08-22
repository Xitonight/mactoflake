{
  flake.nixosModules.home-manager =
    {
      pkgs,
      config,
      inputs,
      flakeDir,
      papersDir,
      username,
      email,
      ...
    }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "backup";
        backupCommand = "${pkgs.coreutils}/bin/rm -f";
        extraSpecialArgs = {
          inherit
            inputs
            flakeDir
            papersDir
            username
            email
            ;
          limitedColors = false;
          monitorsConfig = config.mactoflake.hyprland.monitors;
        };
      };
    };
}
