{ config, ... }:

{
  programs.zathura = {
    enable = true;
    options = {
      window-title-home-tilde = true;
      statusbar-basename = true;
      selection-clipboard = "clipboard";
      adjust-open = "width";
      guioptions = "";
      first-page-column = "1:2";
      recolor = true;
      render-loading = true;
    };
    mappings = {
      j = ''feedkeys "<C-Down>"'';
      k = ''feedkeys "<C-Up>"'';
    };
    extraConfig = ''
      include ${config.xdg.configHome}/zathura/colors.zathurarc
    '';
  };
}
