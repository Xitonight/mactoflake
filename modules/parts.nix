{
  inputs,
  ...
}:

{
  imports = [ inputs.home-manager.flakeModules.home-manager ];

  systems = [ "x86_64-linux" ];

  flake.const = {
    username = "xitonight";
    flakeDir = "/home/xitonight/.mactoflake";
    papersDir = "$XDG_PICTURES_DIR/papers";
    email = "xitonight@gmail.com";
  };
}
