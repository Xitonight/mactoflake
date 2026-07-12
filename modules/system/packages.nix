{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- CLI ---
    fd
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
    wget
    usbutils
    inetutils

    # --- Editor ---
    neovim
    gcc
    tree-sitter
    rustc
    cargo

    # --- Desktop / Hyprland ---
    hyprpolkitagent
    cliphist
    udiskie
    hyprshot
    hyprpicker
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

    # --- Notifications ---
    swaynotificationcenter

    # --- Desktop apps ---
    obsidian
    telegram-desktop
    cava
    obs-studio
    scrcpy

    # --- Fun ---
    cowsay
    figlet
    lolcat
    pipes

    # --- Build ---
    cmake
    gnumake
  ];

}
