{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- CLI ---
    bat
    eza
    fd
    ripgrep
    killall
    delta
    gh
    btop
    fastfetch
    tmuxinator
    rsync
    just
    wl-clipboard
    unzip
    fzf
    zoxide
    pay-respects
    lazygit
    oh-my-posh
    sesh
    xdg-user-dirs

    # --- Editor ---
    neovim
    gcc
    rustc
    cargo

    # --- Desktop / Hyprland ---
    hyprpolkitagent
    cliphist
    udiskie
    stow
    hyprshot
    grim
    slurp
    playerctl
    brightnessctl
    ddcutil
    wiremix

    # --- GTK / Qt ---
    papirus-icon-theme
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    libsForQt5.qtwayland
    qt6.qtwayland
    nwg-look

    # --- Theming ---
    matugen
    awww
    pywal

    # --- Rofi ---
    (pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; })
    pkgs.rofi-rbw

    # --- Notifications ---
    swaynotificationcenter

    # --- Desktop apps ---
    obsidian
    telegram-desktop
    cava
    kitty

    # --- Media ---
    yazi
    zathura
    mpv
  ];
}
