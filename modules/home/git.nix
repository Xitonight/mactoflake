{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Xitonight";
        email = "xitonight@gmail.com";
      };
      safe.directory = "/etc/nixos";
    };
  };

  programs.delta = {
    enable = true;
    options = {
      line-numbers = true;
      navigate = true;
      side-by-side = true;
      syntax-theme = "base16";
    };
  };
}
