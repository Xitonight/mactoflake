{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- CLI ---
    fd
    file
    ripgrep
    killall
    fastfetch
    tmuxinator
    rsync
    just
    wl-clipboard
    unzip
    lazygit
    sesh
    xdg-user-dirs
    zip
    wtype

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

    # --- Build ---
    cmake
    gnumake
  ];

}
