{ pkgs, inputs, ... }:
let
  firefox-addons = pkgs.firefox-addons;
  disabled = map (id: {
    inherit id;
    disabled = true;
  });
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

        # Remove popups for "ask to save password" and translations
        "signon.rememberSignons" = false;
        "browser.translations.automaticallyPopup" = false;

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
          searchix-nixos = {
            name = "Searchix nixos options";
            urls = [
              {
                template = "https://searchix.ovh/options/nixos/search?query={searchTerms}";
              }
            ];
            definedAliases = [ "@nixo" ];
          };
          searchix-hm = {
            name = "Searchix home-manager options";
            urls = [
              {
                template = "https://searchix.ovh/options/home-manager/search?query={searchTerms}";
              }
            ];
            definedAliases = [ "@nixh" ];
          };
          searchix-all = {
            name = "Searchix all";
            urls = [
              {
                template = "https://searchix.ovh/?query={searchTerms}";
              }
            ];
            definedAliases = [ "@nixa" ];
          };
          searchix-pkgs = {
            name = "Searchix pkgs";
            urls = [
              {
                template = "https://searchix.ovh/packages/nixpkgs/search?query={searchTerms}";
              }
            ];
            definedAliases = [ "@nixp" ];
          };
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

      containers = {
        Personal = {
          color = "purple";
          icon = "fingerprint";
          id = 1;
        };
        Uni = {
          color = "blue";
          icon = "briefcase";
          id = 2;
        };
        Demetra = {
          color = "blue";
          icon = "briefcase";
          id = 3;
        };
        Sedapta = {
          color = "yellow";
          icon = "briefcase";
          id = 4;
        };
      };

      spacesForce = true;
      spaces = {
        "Uni" = {
          id = "a6de093b-408d-4206-961d-ab11f989d41b";
          position = 1000;
          icon = "🎓";
          container = 2;
          pins = {
            "AulaWeb" = {
              id = "28a03b59-e235-4b1b-9dac-e484d7d9d510";
              url = "https://2025.aulaweb.unige.it/my/";
            };
            "Gemini" = {
              id = "4df0c698-8616-4b1e-bd18-d5422cb4630a";
              url = "https://gemini.google.com/app";
            };
          };
        };
        "Dots" = {
          id = "edd11fae-1fc5-494b-9041-325e5759198c";
          position = 2000;
          icon = "💠";
          container = 1;
          pins = {
            "My-GitHub" = {
              id = "f74716f2-9475-486b-8321-9c23e2941c2d";
              url = "https://github.com/Xitonight?tab=repositories";
            };
          };
        };
        "Default" = {
          id = "8015cee6-9f50-4dc1-8ecf-baa25f8c8fd7";
          position = 3000;
          icon = "🩷";
          container = 1;
        };
        "Projects" = {
          id = "beb980ca-fcde-38ba-9d54-04a84569e2c3";
          position = 4000;
          icon = "🌙";
          container = 1;
        };
        "Work" = {
          id = "decf5613-69b4-4e57-927a-68ad8068808e";
          position = 5000;
          icon = "🗂";
          pins = {
            "Demetra" = {
              id = "2898cb7f-bee0-4185-99a9-f60a507fa7e6";
              isFolderCollapsed = false;
              editedTitle = true;
              position = 200;
              pins = {
                "Teams" = {
                  id = "1a223ccc-25b0-43e1-a3a5-3bd5e3e8cf40";
                  url = "https://teams.cloud.microsoft/";
                  container = 3;
                  position = 201;
                };
                "Outlook" = {
                  id = "28c0d9e7-dfb2-42c1-aa91-65e5744277db";
                  url = "https://outlook.office.com/mail/";
                  container = 3;
                  position = 202;
                };
              };
            };
            "Sedapta" = {
              id = "7b0650a5-0e2f-480f-966d-ffe397973037";
              isFolderCollapsed = false;
              editedTitle = true;
              position = 300;
              pins = {
                "Teams" = {
                  id = "3f6eec3a-0862-42ed-8a70-41d0a3181f65";
                  url = "https://teams.cloud.microsoft/";
                  container = 4;
                  position = 301;
                };
                "Outlook" = {
                  id = "617552bd-f56c-4aa6-babf-6b919b756a07";
                  url = "https://outlook.office.com/mail/";
                  container = 4;
                  position = 302;
                };
              };
            };
          };
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
        "Gmail" = {
          id = "682fa99f-a637-47f5-addd-71564cc5ed74";
          url = "https://mail.google.com";
          position = 102;
          isEssential = true;
        };
        "Gemini" = {
          id = "57c4cf02-c422-4631-bbc8-4fade8d1b883";
          url = "https://gemini.google.com/app";
          position = 103;
          isEssential = true;
        };
      };

      extensions.packages = with firefox-addons; [
        ublock-origin
        vimium
        onepassword-password-manager
      ];

      keyboardShortcutsVersion = 19;
      keyboardShortcuts =
        # Ported from ~/.xidots/dots/.zen/xitonight/zen-keyboard-shortcuts.json
        disabled [
          "key_undoCloseWindow"
          "key_toggleReaderMode"
          "key_exitFullScreen"
          "key_duplicateTab"
          "key_switchTextDirection"
          "zen-new-unsynced-window"
          "zen-glance-expand"
          "key_newNavigator"
          "key_closeWindow"
          "key_quitApplication"
          "goHome"
          "key_gotoHistory"
          "key_viewSource"
          "key_viewInfo"
          "showAllHistoryKb"
          "addBookmarkAsKb"
          "manBookmarkKb"
          "key_openDownloads"
          "key_openAddons"
          "key_enterFullScreen"
          "key_aboutProcesses"
          "viewGenaiChatSidebarKb"
          "toggleSidebarKb"
          "key_showAllTabs"
          "key_wrCaptureCmd"
          "key_wrToggleCaptureSequenceCmd"
          "key_accessibility"
          "key_dom"
          "key_storage"
          "key_performance"
          "key_styleeditor"
          "key_netmonitor"
          "key_jsdebugger"
          "key_webconsole"
          "key_inspector"
          "key_responsiveDesignMode"
          "key_browserConsole"
          "key_browserToolbox"
          "key_toggleToolbox"
          "focusURLBar"
        ]

        ++ [
          # Navigation
          {
            id = "goBackKb";
            key = "h";
            modifiers.shift = true;
          }
          {
            id = "goForwardKb";
            key = "l";
            modifiers.shift = true;
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
            key = "5";
            modifiers.accel = true;
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

  home.sessionVariables = {
    MOZ_DBUS_REMOTE = "1";
  };
}
