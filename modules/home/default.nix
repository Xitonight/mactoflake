{ inputs, ... }:

{
  home.username = "xitonight";
  home.homeDirectory = "/home/xitonight";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  imports = [
    ./btop.nix
    ./eza.nix
    ./fzf.nix
    ./fsh
    ./git.nix
    ./gtk.nix
    ./hypr
    ./kitty.nix
    ./lazygit.nix
    ./matugen
    ./nvim
    ./oh-my-posh.nix
    ./opencode
    ./pay-respects.nix
    ./qt.nix
    ./rbw.nix
    ./rofi
    ./swaync
    ./tmux.nix
    ./xdg.nix
    ./yazi.nix
    ./zathura.nix
    ./zsh.nix
    ./zen.nix
    ./zoxide.nix
  ];
}
