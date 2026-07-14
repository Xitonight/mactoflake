{
  pkgs,
  lib,
  osConfig,
  ...
}:

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
    signing = {
      signByDefault = true;
      format = "ssh";
      signer = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      key = osConfig.mactoflake.git.signingKey;
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
