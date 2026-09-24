{
  flake.homeModules.herdr =
    {
      lib,
      osConfig,
      pkgs,
      config,
      inputs,
      ...
    }:
    let
      multiplexer = if osConfig == null then "tmux" else osConfig.mactoflake.shell.multiplexer;

      tomlFormat = pkgs.formats.toml { };

      navigatorSrc = pkgs.fetchFromGitHub {
        owner = "thanhdat77";
        repo = "herdr-navigator";
        rev = "v0.3.6";
        hash = "sha256-+xtBu4m2YenFH+W3Sv7atDvcsgChS5mKXgVgKomM768=";
      };

      herdrNavigator = pkgs.rustPlatform.buildRustPackage {
        pname = "herdr-navigator";
        version = "0.3.6";
        src = navigatorSrc;
        cargoLock.lockFile = "${navigatorSrc}/Cargo.lock";
      };

      herdrNavigatorPlugin = pkgs.runCommand "herdr-navigator-plugin" { } ''
        mkdir -p $out/target/release
        cp ${herdrNavigator}/bin/herdr-navigator $out/target/release/herdr-navigator
        cp ${navigatorSrc}/herdr-plugin.toml $out/herdr-plugin.toml
      '';

      splitsSrc = pkgs.fetchFromGitHub {
        owner = "lmilojevicc";
        repo = "herdr-splits.nvim";
        rev = "94f30cf4e9ac76ddf185a3acd0977be728fa4106";
        hash = "sha256-7rHAPSjd2n16FGOcqI/1KNHl1yCmMOVVwiJl/eEU9n8=";
      };

      herdrSplitsPlugin = pkgs.runCommand "herdr-splits-plugin" { } ''
        mkdir -p $out/scripts
        cp ${splitsSrc}/herdr-plugin.toml $out/herdr-plugin.toml
        cp ${splitsSrc}/scripts/*.sh $out/scripts/
      '';
    in
    {
      programs.herdr = lib.mkIf (multiplexer == "herdr") {
        enable = true;
        package = inputs.herdr.packages.${pkgs.system}.herdr;
        settings = {
          onboarding = false;

          theme.custom.panel_bg = "transparent";

          keys = {
            prefix = "ctrl+space";
            reload_config = "prefix+r";
            resize_mode = "prefix+shift+r";
            detach = "prefix+d";
            copy_mode = [
              "prefix+["
              "ctrl+y"
            ];
            previous_tab = "alt+shift+h";
            next_tab = "alt+shift+l";
            focus_pane_left = "prefix+h";
            focus_pane_down = "prefix+j";
            focus_pane_up = "prefix+k";
            focus_pane_right = "prefix+l";
            split_vertical = "prefix+percent";
            split_horizontal = "prefix+double_quote";
            command = [
              {
                key = "ctrl+h";
                type = "plugin_action";
                command = "herdr-splits.nav-left";
                description = "focus pane or nvim split left";
              }
              {
                key = "ctrl+j";
                type = "plugin_action";
                command = "herdr-splits.nav-down";
                description = "focus pane or nvim split down";
              }
              {
                key = "ctrl+k";
                type = "plugin_action";
                command = "herdr-splits.nav-up";
                description = "focus pane or nvim split up";
              }
              {
                key = "ctrl+l";
                type = "plugin_action";
                command = "herdr-splits.nav-right";
                description = "focus pane or nvim split right";
              }
              {
                key = "ctrl+shift+h";
                type = "plugin_action";
                command = "herdr-splits.resize-left";
                description = "resize pane or nvim split left";
              }
              {
                key = "ctrl+shift+j";
                type = "plugin_action";
                command = "herdr-splits.resize-down";
                description = "resize pane or nvim split down";
              }
              {
                key = "ctrl+shift+k";
                type = "plugin_action";
                command = "herdr-splits.resize-up";
                description = "resize pane or nvim split up";
              }
              {
                key = "ctrl+shift+l";
                type = "plugin_action";
                command = "herdr-splits.resize-right";
                description = "resize pane or nvim split right";
              }
              {
                key = "alt+s";
                type = "plugin_action";
                command = "herdr-navigator.open";
                description = "jump to anything";
              }
              {
                key = "alt+l";
                type = "plugin_action";
                command = "herdr-navigator.jump-back";
                description = "jump to previous workspace";
              }
              {
                key = "alt+g";
                type = "popup";
                command = "lazygit";
                description = "lazygit";
                width = "80%";
                height = "80%";
              }
            ];
          };

          ui = {
            confirm_close = false;
            sidebar_start_collapsed = true;
            sidebar_collapsed_mode = "hidden";
            pane_outer_borders = false;
            pane_gaps = false;
            pane_scrollbars = false;
            tab_bar_right = [
              {
                type = "datetime";
                format = "%H:%M";
              }
            ];
            toast.delivery = "system";
          };
        };
      };

      xdg.configFile."herdr/plugins/config/herdr-navigator/config.toml" =
        lib.mkIf (multiplexer == "herdr")
          {
            source = tomlFormat.generate "herdr-navigator-config.toml" {
              picker.vim_mode = true;
            };
          };

      home.activation.herdrPlugins = lib.mkIf (multiplexer == "herdr") (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          link_plugin() {
            if ! grep -q "$2" "$HOME/.config/herdr/plugins.json" 2>/dev/null; then
              $DRY_RUN_CMD ${config.programs.herdr.package}/bin/herdr plugin unlink "$1" 2>/dev/null || true
              # never fail the switch: a stale running herdr server rejects plugin
              # commands (protocol mismatch) until restarted; the grep retries on next switch
              $DRY_RUN_CMD ${config.programs.herdr.package}/bin/herdr plugin link "$2" || true
            fi
          }
          link_plugin herdr-navigator '${herdrNavigatorPlugin}'
          link_plugin herdr-splits '${herdrSplitsPlugin}'
        ''
      );
    };
}
