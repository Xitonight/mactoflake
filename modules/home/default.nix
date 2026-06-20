{ ... }:

{
  home.username = "xitonight";
  home.homeDirectory = "/home/xitonight";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  imports = [
    ./env.nix
    ./shell/zsh.nix
    ./terminal/kitty.nix
    ./terminal/tmux.nix
    ./editor/neovim.nix
    ./cli/git.nix
    ./cli/packages.nix
    ./desktop/hyprland.nix
  ];
}
