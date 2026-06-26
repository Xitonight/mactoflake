{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      tmux-floax
      vim-tmux-navigator
      yank
    ];
  };
}
