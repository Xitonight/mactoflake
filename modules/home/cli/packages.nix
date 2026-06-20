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
    lazygit
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

  # Verbatim config files (no Home Manager module, or config is hand-written).
  xdg.configFile."lazygit/config.yml".source = ./lazygit.yml;
  xdg.configFile."btop/btop.conf".source = ./btop.conf;
  xdg.configFile."sesh/sesh.toml".source = ./sesh.toml;
  xdg.configFile."oh-my-posh/config.toml".source = ./oh-my-posh.toml;
}
