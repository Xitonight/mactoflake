{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    eza
    fzf
    zoxide
    fd
    ripgrep
    delta
    gh
    btop
    fastfetch
    sesh
    tmuxinator
    pay-respects
    oh-my-posh
    rsync
    just
    wl-clipboard
    unzip
  ];

  programs.lazygit = {
    enable = true;
    settings = {
      quitOnTopLevelReturn = true;
      gui.theme.selectedLineBgColor = [ "bold" "underline" ];
    };
  };

  # Verbatim config files (no Home Manager module, or config is hand-written).
  xdg.configFile."btop/btop.conf".source = ./btop.conf;
  xdg.configFile."sesh/sesh.toml".source = ./sesh.toml;
  xdg.configFile."oh-my-posh/config.toml".source = ./oh-my-posh.toml;
}
