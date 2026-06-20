{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      vim-tmux-navigator
      yank
      tmux-floax
    ];
    extraConfig = builtins.readFile ./tmux.conf;
  };
}
