{
  inputs,
  ...
}:
{
  flake.homeModules.vicinae =
    {
      pkgs,
      config,
      ...
    }:
    {
      imports = [ inputs.vicinae.homeManagerModules.default ];

      programs.vicinae = {
        enable = true;
        package = pkgs.vicinae;
        enableFirefoxIntegration = false;
        enableChromeIntegration = false;
        systemd = {
          enable = true;
          environment = {
            USE_LAYER_SHELL = 1;
          };
        };
        settings = {
          theme = {
            light.name = "matugen";
            dark.name = "matugen";
          };
          providers = {
            "@sovereign/awww-switcher".preferences = {
              wallpaperPath = "${config.xdg.userDirs.pictures}/papers";
              colorGenTool = "matugen";
            };
            "@bl4zee1g/bitwarden".entrypoints."browse-vault".alias = "bw";
            "@knoopx/nix".entrypoints = {
              options.alias = "nx";
              home-manager-options.alias = "nxh";
            };
            files.entrypoints.search.alias = "ff";
            system.entrypoints.run.alias = "!";
            wm.entrypoints.switch-workspaces.alias = "ws";
          };
        };

        extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
          (awww-switcher.overrideAttrs { name = "awww-switcher"; })
          (bitwarden.overrideAttrs { name = "bitwarden"; })
          (nix.overrideAttrs { name = "nix"; })
        ];

      };

      home.file.".local/share/applications/nvim.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Neovim
        GenericName=Text Editor
        Comment=Edit files in a floating kitty window
        Exec=kitty --class kitty-nvim nvim -- %F
        Terminal=false
        Icon=nvim
        Categories=Utility;TextEditor;Development;
        MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;
        StartupNotify=false
      '';
    };
}
