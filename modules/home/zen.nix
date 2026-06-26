{ pkgs, inputs, ... }:

{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    setAsDefaultBrowser = true;

    policies = {
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisablePocket = true;
    };

    profiles.default = {
      settings = {
        # Fonts (ported from ~/.xidots/dots/.zen/xitonight/user.js)
        "font.name.monospace.x-western" = "monospace";
        "font.name.sans-serif.x-western" = "sans-serif";
        "font.name.serif.x-western" = "serif";
        "font.size.monospace.x-western" = 14;
        "font.size.variable.x-western" = 14;

        # UI
        "zen.workspaces.continue-where-left-off" = true;
        "zen.view.compact.hide-tabbar" = true;
        "zen.workspaces.separate-essentials" = false; # Show essential pins in all workspaces
        "zen.urlbar.behavior" = "float";
        "zen.tabs.show-newtab-vertical" = false;
        "zen.tabs.vertical.right-side" = true;
        "zen.view.compact.toolbar-flash-popup" = true;
      };

      mods = [
        "e122b5d9-d385-4bf8-9971-e137809097d0" # No Top Sites
        "253a3a74-0cc4-47b7-8b82-996a64f030d5" # Floating History
      ];

      search = {
        force = true;
        default = "unduck";
        engines = {
          unduck = {
            name = "Unduck";
            urls = [
              {
                template = "https://unduck.link/?q={searchTerms}";
                params = [
                  {
                    name = "query";
                    value = "searchTerms";
                  }
                ];
              }
            ];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@ud"];
          };
        };
      };

      bookmarks = {
        force = true;
        settings = [
          {
            name = "Quick Links";
            toolbar = true;
            bookmarks = [
              {
                name = "GitHub";
                url = "https://github.com";
              }
            ];
          }
        ];
      };

      spacesForce = true;
      spaces = {
        "General" = {
          id = "c6de089c-410d-4206-961d-ab11f988d40a";
          position = 1000;
          icon = "🏠";
        };
        "Work" = {
          id = "cdd10fab-4fc5-494b-9041-325e5759195b";
          position = 2000;
          icon = "💼";
        };
      };

      pinsForce = true;
      pinsForceAction = "remove";
      pins = {
        "GitHub" = {
          id = "48e8a119-5a14-4826-9545-91c8e8dd3bf6";
          url = "https://github.com";
          position = 101;
          isEssential = true;
        };
        "Whatsapp Web" = {
          id = "ce24e4c0-d85b-416f-947c-abf47a2c76b9";
          url = "https://web.whatsapp.com";
          position = 102;
          isEssential = true;
        };
        "Gmail" = {
          id = "682fa99f-a637-47f5-addd-71564cc5ed74";
          url = "https://mail.google.com";
          position = 103;
          isEssential = true;
        };
      };

      keyboardShortcutsVersion = 19;
      keyboardShortcuts = [
        # Ported from ~/.xidots/dots/.zen/xitonight/zen-keyboard-shortcuts.json

        # Disabled defaults
        {
          id = "key_undoCloseWindow";
          disabled = true;
        }
        {
          id = "key_toggleReaderMode";
          disabled = true;
        }
        {
          id = "key_exitFullScreen";
          disabled = true;
        }
        {
          id = "key_duplicateTab";
          disabled = true;
        }

        # Zen-specific
        {
          id = "zen-compact-mode-toggle";
          key = "e";
          modifiers.accel = true;
        }
        {
          id = "zen-workspace-forward";
          key = "l";
          modifiers = {
            alt = true;
            shift = true;
          };
        }
        {
          id = "zen-workspace-backward";
          key = "h";
          modifiers = {
            alt = true;
            shift = true;
          };
        }
        {
          id = "zen-split-view-grid";
          key = "g";
          modifiers = {
            alt = true;
            accel = true;
          };
        }
        {
          id = "zen-split-view-vertical";
          key = "%";
          modifiers = {
            shift = true;
            accel = true;
          };
        }
        {
          id = "zen-split-view-horizontal";
          key = ";";
          modifiers.accel = true;
        }
        {
          id = "zen-split-view-unsplit";
          key = "x";
          modifiers = {
            shift = true;
            accel = true;
          };
        }
        {
          id = "zen-copy-url";
          key = "c";
          modifiers = {
            shift = true;
            accel = true;
          };
        }
      ];
    };
  };
}
