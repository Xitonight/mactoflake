{ self, ... }:

{
  flake.homeModules.base =
    { username, ... }:
    {
      home = {
        inherit username;
        homeDirectory = "/home/${username}";
        stateVersion = "26.05";
      };

      programs.home-manager.enable = true;
    };

  flake.homeImports = [
    self.homeModules.base
    self.homeModules.bat
    self.homeModules.btop
    self.homeModules.devenv
    self.homeModules.eza
    self.homeModules.fzf
    self.homeModules.fsh
    self.homeModules.git
    self.homeModules.gtk
    self.homeModules.hyprland
    self.homeModules.kitty
    self.homeModules.lazygit
    self.homeModules.matugen
    self.homeModules.mpv
    self.homeModules.nvim
    self.homeModules.oh-my-posh
    self.homeModules.opencode
    self.homeModules.pay-respects
    self.homeModules.qt
    self.homeModules.rofi
    self.homeModules.scripts
    self.homeModules.secretspec
    self.homeModules.ssh
    self.homeModules.starship
    self.homeModules.swaync
    self.homeModules.tmux
    self.homeModules.vesktop
    self.homeModules.xdg
    self.homeModules.yazi
    self.homeModules.zathura
    self.homeModules.zen
    self.homeModules.zoxide
    self.homeModules.zsh
  ];
}
