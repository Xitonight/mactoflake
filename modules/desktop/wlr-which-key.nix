{
  flake.homeModules.wlr-which-key =
    { pkgs, lib, ... }:
    let
      kanataToggle = "if systemctl is-active --quiet kanata; then systemctl stop kanata && notify-send -t 2000 kanata disabled; else systemctl start kanata && notify-send -t 2000 kanata enabled; fi";

      kbdLayoutNext = ''hyprctl switchxkblayout current next && notify-send -t 1500 "Layout: $(hyprctl devices | awk '/Main: yes/{f=1} f && /Active keymap:/{sub(/.*Active keymap: /, ""); print; exit}')"'';

      menu = [
        {
          key = "p";
          desc = "Power";
          submenu = [
            {
              key = "l";
              desc = "Lock";
              cmd = "loginctl lock-session";
            }
            {
              key = "s";
              desc = "Suspend";
              cmd = "systemctl suspend";
            }
            {
              key = "r";
              desc = "Reboot";
              cmd = "systemctl reboot";
            }
            {
              key = "o";
              desc = "Power off";
              cmd = "systemctl poweroff";
            }
            {
              key = "e";
              desc = "Exit Hyprland";
              cmd = "hyprctl dispatch exit";
            }
          ];
        }
        {
          key = "s";
          desc = "Screenshot";
          submenu = [
            {
              key = "o";
              desc = "Output";
              cmd = "hyprshot -m output -m active --clipboard-only";
            }
            {
              key = "w";
              desc = "Window";
              cmd = "hyprshot -m window -m active --clipboard-only";
            }
            {
              key = "r";
              desc = "Region";
              cmd = "hyprshot -m region --clipboard-only";
            }
          ];
        }
        {
          key = "t";
          desc = "Toggles";
          submenu = [
            {
              key = "k";
              desc = "Kanata";
              cmd = kanataToggle;
              keep_open = true;
            }
            {
              key = "n";
              desc = "Notifications";
              cmd = "swaync-client -t -sw";
              keep_open = true;
            }
            {
              key = "f";
              desc = "Float";
              cmd = "hyprctl dispatch togglefloating";
              keep_open = true;
            }
            {
              key = "p";
              desc = "Pin";
              cmd = "hyprctl dispatch pin";
              keep_open = true;
            }
            {
              key = "s";
              desc = "Special workspace";
              cmd = "hyprctl dispatch togglespecialworkspace";
              keep_open = true;
            }
          ];
        }
        {
          key = "a";
          desc = "Apps";
          submenu = [
            {
              key = "t";
              desc = "Floating terminal";
              cmd = "RAW_TERM=1 kitty --class kitty-floating";
            }
            {
              key = "b";
              desc = "btop";
              cmd = "kitty --class kitty-btop btop";
            }
            {
              key = "v";
              desc = "Volume";
              cmd = "kitty --class kitty-wiremix wiremix";
            }
            {
              key = "n";
              desc = "Network";
              cmd = "kitty --class kitty-nmtui --override window_padding_width=0 nmtui";
            }
            {
              key = "k";
              desc = "Keyboard layout";
              cmd = kbdLayoutNext;
            }
          ];
        }
        {
          key = "d";
          desc = "Debug";
          submenu = [
            {
              key = "c";
              desc = "Dump clients";
              cmd = ''hyprctl clients > $HOME/.cache/clients.txt && notify-send -t 1500 "Clients dumped"'';
            }
            {
              key = "l";
              desc = "Dump layers";
              cmd = ''hyprctl layers > $HOME/.cache/layers.txt && notify-send -t 1500 "Layers dumped"'';
            }
          ];
        }
      ];
    in
    {
      home.packages = [ pkgs.wlr-which-key ];

      xdg.configFile."wlr-which-key/config.yaml".text = lib.generators.toYAML { } {
        font = "CaskaydiaCove Nerd Font 12";
        background = "#11111bd0";
        color = "#cdd6f4";
        border = "#89b4fa";
        separator = " ➜ ";
        border_width = 2;
        corner_r = 10;
        padding = 15;
        anchor = "center";
        inhibit_compositor_keyboard_shortcuts = true;
        auto_kbd_layout = true;
        inherit menu;
      };
    };
}
