{ ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      volume = 75;
      volume-max = 100;
      keep-open = "yes";
      osd-font = "CaskaydiaCove Nerd Font";
    };
  };
}
