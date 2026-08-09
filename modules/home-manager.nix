{
  ...
}:

{
  flake.nixosModules.home-manager =
    {
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
