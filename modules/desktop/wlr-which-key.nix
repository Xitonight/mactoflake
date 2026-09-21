{
  flake.homeModules.wlr-which-key =
    { pkgs, lib, ... }:
    let
      kanataToggle = "if systemctl is-active --quiet kanata; then systemctl stop kanata && notify-send -t 2000 kanata disabled; else systemctl start kanata && notify-send -t 2000 kanata enabled; fi";

      kbdLayoutNext = ''hyprctl switchxkblayout current next && notify-send -t 1500 "Layout: $(hyprctl devices | awk '/Main: yes/{f=1} f && /Active keymap:/{sub(/.*Active keymap: /, ""); print; exit}')"'';

      shot =
        mode:
        ''mkdir -p ~/.cache/hyprshot && hyprshot ${mode} --clipboard-only -s && wl-paste --type image/png > ~/.cache/hyprshot/last.png && notify-send -t 5000 -a Hyprshot -i ~/.cache/hyprshot/last.png "Screenshot" "Copied to clipboard"'';

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
              cmd = shot "-m output -m active";
            }
            {
              key = "w";
              desc = "Window";
              cmd = shot "-m window -m active";
            }
            {
              key = "r";
              desc = "Region";
              cmd = shot "-m region";
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
      renderConfig =
        {
          background,
          color,
          border,
        }:
        lib.generators.toYAML { } (
          {
            font = "Poppins 14";
            separator = " ➜ ";
            border_width = 3;
            corner_r = 16;
            padding = 24;
            anchor = "bottom-right";
            margin_right = 30;
            margin_bottom = 30;
            inhibit_compositor_keyboard_shortcuts = true;
            auto_kbd_layout = true;
            inherit menu;
          }
          // {
            inherit background color border;
          }
        );
    in
    {
      home.packages = [
        pkgs.wlr-which-key
        (pkgs.writeShellScriptBin "wlr-which-key-menu" ''
          cache="''${XDG_CACHE_HOME:-$HOME/.cache}/wlr-which-key"
          template="''${XDG_CONFIG_HOME:-$HOME/.config}/wlr-which-key/config.template.yaml"
          colors="$cache/colors.env"
          if [ ! -f "$colors" ] || [ ! -f "$template" ]; then
            exec ${lib.getExe pkgs.wlr-which-key}
          fi
          . "$colors"
          mkdir -p "$cache"
          sed -e "s|@BACKGROUND@|$BACKGROUND|" -e "s|@COLOR@|$COLOR|" -e "s|@BORDER@|$BORDER|" "$template" > "$cache/config.yaml"
          exec ${lib.getExe pkgs.wlr-which-key} "$cache/config.yaml"
        '')
      ];

      xdg.configFile = {
        "wlr-which-key/config.yaml".text = renderConfig {
          background = "#11111bf2";
          color = "#cdd6f4";
          border = "#89b4fa";
        };

        "wlr-which-key/config.template.yaml".text = renderConfig {
          background = "@BACKGROUND@";
          color = "@COLOR@";
          border = "@BORDER@";
        };
      };
    };
}
