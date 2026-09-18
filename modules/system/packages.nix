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
        tldr

        # --- Editor ---
        neovim
        gcc
        tree-sitter
        rustc
        cargo

        # --- Desktop / Hyprland ---
        hyprpolkitagent
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
