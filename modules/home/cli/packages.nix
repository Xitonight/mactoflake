{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    eza
    fd
    ripgrep
    delta
    gh
    btop
    fastfetch
    tmuxinator
    rsync
    just
    wl-clipboard
    unzip
  ];

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    options = [ "--cmd" "cd" ];
  };

  programs.pay-respects = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
  };

  programs.lazygit = {
    enable = true;
    settings = {
      quitOnTopLevelReturn = true;
      gui.theme.selectedLineBgColor = [ "bold" "underline" ];
    };
  };

  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    settings = {
      version = 2;
      final_space = true;
      console_title_template = "{{ .Shell }} in {{ .Folder }}";
      async = true;
      blocks = [
        {
          type = "prompt";
          alignment = "left";
          newline = true;
          segments = [
            {
              type = "path";
              style = "plain";
              background = "transparent";
              foreground = "16";
              template = "{{ .Path }}";
              properties.style = "full";
            }
            {
              type = "git";
              style = "plain";
              foreground = "p:grey";
              background = "transparent";
              template =
                " {{ .HEAD }}{{ if or (.Working.Changed) (.Staging.Changed) }}*{{ end }} <cyan>{{ if gt .Behind 0 }}⇣{{ end }}{{ if gt .Ahead 0 }}⇡{{ end }}</>";
              properties = {
                branch_icon = "";
                commit_icon = "@";
                fetch_status = true;
              };
            }
          ];
        }
        {
          type = "rprompt";
          overflow = "hidden";
          segments = [{
            type = "executiontime";
            style = "plain";
            foreground = "yellow";
            background = "transparent";
            template = "{{ .FormattedMs }}";
            properties.threshold = 5000;
          }];
        }
        {
          type = "prompt";
          alignment = "left";
          newline = true;
          segments = [{
            type = "text";
            style = "plain";
            foreground_templates =
              [ "{{if gt .Code 0}}red{{end}}" "{{if eq .Code 0}}green{{end}}" ];
            background = "transparent";
            template = "❯";
          }];
        }
      ];
      transient_prompt = {
        foreground_templates =
          [ "{{if gt .Code 0}}red{{end}}" "{{if eq .Code 0}}green{{end}}" ];
        background = "transparent";
        template = "❯ ";
      };
      secondary_prompt = {
        foreground = "magenta";
        background = "transparent";
        template = "❯❯ ";
      };
    };
  };

  programs.sesh = {
    enable = true;
    enableAlias = false;
    enableTmuxIntegration = false;
    settings = {
      blacklist = [ "scratch" ];
      dir_length = 2;
      default_session = {
        startup_command = "tmuxinator start --append && exit || clear";
        preview_command = "eza --all -1 --git --icons --color=always {}";
      };
      session = [
        {
          name = "papers";
          path = "~/Pictures/Wallpapers";
          preview_command =
            "eza -1 --icons --color=always ~/Pictures/Wallpapers";
        }
        {
          name = "tmux conf";
          path = "~/.config/tmux";
          startup_command = "nvim tmux.conf";
          preview_command = "bat --color=always ~/.config/tmux/tmux.conf";
        }
        {
          name = "nvim conf";
          path = "~/.config/nvim";
          startup_command = "nvim";
          preview_command = "bat --color=always ~/.config/nvim/init.lua";
        }
      ];
    };
  };

  # Verbatim config files (no Home Manager module, or config is hand-written).
  xdg.configFile."btop/btop.conf".source = ./btop.conf;
}
