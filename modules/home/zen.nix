{ pkgs, inputs, ... }:
let
  firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
in
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
            definedAliases = [ "@ud" ];
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
        "Uni" = {
          id = "a6de089b-408d-4206-961d-ab11f989d41b";
          position = 1000;
          icon = "🎓";
        };
        "Dots" = {
          id = "edd11fae-4fc5-494b-9041-325e5759198c";
          position = 2000;
          icon = "💠";
        };
        "Default" = {
          id = "8015cee3-9f50-4dc1-8ecf-baa25f8c8fd7";
          position = 3000;
          icon = "🩷";
        };
        "Projects" = {
          id = "beb980ca-fcde-42ba-9d54-04a84569e2c3";
          position = 4000;
          icon = "🌙";
        };
      };

      pinsForce = true;
      pinsForceAction = "remove";
      pins = {
        "Whatsapp Web" = {
          id = "ce24e4c0-d85b-416f-947c-abf47a2c76b9";
          url = "https://web.whatsapp.com";
          position = 101;
          isEssential = true;
        };
        "GitHub" = {
          id = "48e8a119-5a14-4826-9545-91c8e8dd3bf6";
          url = "https://github.com";
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

      extensions.packages = with firefox-addons; [
        ublock-origin
        vimium
      ];

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
