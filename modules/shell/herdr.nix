{
  flake.homeModules.herdr =
    {
      lib,
      osConfig,
      pkgs,
      config,
      ...
    }:
    let
      multiplexer = if osConfig == null then "tmux" else osConfig.mactoflake.shell.multiplexer;

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
    in
    {
      programs.herdr = lib.mkIf (multiplexer == "herdr") {
        enable = true;
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
            focus_pane_left = [
              "prefix+h"
              "ctrl+h"
            ];
            focus_pane_down = [
              "prefix+j"
              "ctrl+j"
            ];
            focus_pane_up = [
              "prefix+k"
              "ctrl+k"
            ];
            focus_pane_right = [
              "prefix+l"
              "ctrl+l"
            ];
            resize_pane_left = "ctrl+shift+h";
            resize_pane_down = "ctrl+shift+j";
            resize_pane_up = "ctrl+shift+k";
            resize_pane_right = "ctrl+shift+l";
            command = [
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
              {
                key = "alt+f";
                type = "popup";
                # HERDR_ENV guard: popups are not panes, so zshrc would otherwise nest herdr inside the popup
                command = ''HERDR_ENV=1 exec "''${SHELL:-sh}"'';
                description = "scratch terminal";
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

      home.activation.herdrNavigatorPlugin = lib.mkIf (multiplexer == "herdr") (
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if ! grep -q '${herdrNavigatorPlugin}' "$HOME/.config/herdr/plugins.json" 2>/dev/null; then
            $DRY_RUN_CMD ${config.programs.herdr.package}/bin/herdr plugin unlink herdr-navigator 2>/dev/null || true
            $DRY_RUN_CMD ${config.programs.herdr.package}/bin/herdr plugin link ${herdrNavigatorPlugin}
          fi
        ''
      );
    };
}
