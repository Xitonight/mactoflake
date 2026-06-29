{ pkgs, ... }:

{
  programs.rbw = {
    enable = true;
    settings = {
      email = "xitonight@gmail.com";
      lock_timeout = 3600;
      sync_interval = 3600;
      pinentry = pkgs.pinentry-qt;
    };
  };
}
