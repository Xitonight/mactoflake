{
  flake.nixosModules.packages =
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
        wl-clipboard
        unzip
        zip
        wtype
        wget
        usbutils
        inetutils
        secretspec
        bitwarden-cli

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

        # --- Theming ---
        matugen
        awww
        pywal

        # --- Rofi ---
        (pkgs.rofi.override { plugins = [ pkgs.rofi-emoji ]; })

        # --- Notifications ---
        swaynotificationcenter
        libnotify

        # --- Desktop apps ---
        bitwarden-desktop
        obsidian
        telegram-desktop
        cava
        obs-studio
        scrcpy
        vial
        qbittorrent
        picard
      ];
    };
}
