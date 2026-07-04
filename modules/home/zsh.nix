{
  pkgs,
  lib,
  config,
  flakeDir,
  ...
}:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    fastSyntaxHighlighting.enable = true;
    defaultKeymap = "viins";

    history = {
      path = "$HOME/.zsh_history";
      size = 10000;
      save = 10000;
      append = true;
      ignoreAllDups = true;
      findNoDups = true;
      saveNoDups = true;
    };

    setOptions = [
      "GLOBDOTS"
      "EXTENDEDGLOB"
    ];

    plugins = [
      {
        name = "fzf-tab";
        src = pkgs.fetchFromGitHub {
          owner = "Aloxaf";
          repo = "fzf-tab";
          rev = "v1.2.0";
          sha256 = "sha256-q26XVS/LcyZPRqDNwKKA9exgBByE0muyuNb0Bbar2lY=";
        };
      }
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    shellAliases = {
      aurora = ''for code in {000..18}; do print -P -- "$code: %F{$code}Color%f"; done'';
      l = "eza -lh --icons=auto";
      ls = "eza --icons=auto";
      la = "eza -A --icons=auto";
      ll = "eza -lha --icons=auto --sort=name --group-directories-first";
      ld = "eza -lhD --icons=auto";
      lt = "eza --icons=auto --tree";
      lta = "eza -a --icons=auto --tree";
      ltt = "eza --icons=auto --tree --level 1";
      ltta = "eza -a --icons=auto --tree --level 1";
      v = "nvim";
      vim = "nvim";
      j = "just";
      open = "xdg-open";
      rsy = "rsync -ahP";
      nvims = "sudoedit";
      mkdir = "mkdir -p";
      rf = "rm -rf";
      lsk = "lsblk";
      mount = "sudo mount";
      umount = "sudo umount";
      zconf = "nvim ${flakeDir}/modules/home/zsh.nix";
      kittyconf = "nvim ${flakeDir}/modules/home/kitty.nix";
      nvconf = "nvim $HOME/.config/nvim";
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
    };

    shellGlobalAliases = {
      "-h" = "-h 2>&1 | bat --language=help --style=plain";
      "--help" = "--help 2>&1 | bat --language=help --style=plain";
      NE = "2>/dev/null";
      NS = ">/dev/null";
      NO = ">/dev/null 2>&1";
      C = "| wl-copy -n";
    };

    initContent =
      let
        zstyleConfig = lib.mkOrder 580 ''
          zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
          zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
          zstyle ':completion:*' menu no
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -A -1 --color=always $realpath'
          zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -A -1 --color=always $realpath'
          zstyle ':fzf-tab:complete:git-(commit|add|diff|restore):*' fzf-preview 'git diff $realpath | delta --syntax-theme=base16'
        '';

        zvmConfig = lib.mkOrder 800 ''
          zvm_config() {
            ZVM_SYSTEM_CLIPBOARD_ENABLED=true
            ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE
            ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
            ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
            ZVM_VISUAL_LINE_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
            ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
            ZVM_VI_HIGHLIGHT_FOREGROUND=0
            ZVM_VI_HIGHLIGHT_BACKGROUND=2
            ZVM_VI_HIGHLIGHT_EXTRASTYLE=bold,underline
          }

          zvm_after_init() {
            bindkey -M viins '^p' history-search-backward
            bindkey -M viins '^n' history-search-forward
            bindkey -M viins ' ' magic-space
            bindkey -M viins '^R' fzf-history-widget
            zle -N sesh-sessions
            bindkey -M vicmd '^s' sesh-sessions
            bindkey -M viins '^s' sesh-sessions
          }
        '';

        shellIntegrations = ''
          stty -ixon

          if [ -z "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
            if [ -z "$(tmux list-clients -t main 2>/dev/null)" ]; then
              tmux attach -t main 2>/dev/null
            fi
          fi
        '';

        functions = lib.mkOrder 1050 ''
          sudo-command-line() {
            [[ -z $BUFFER ]] && zle up-line-or-history
            if [[ $BUFFER == sudo\ * ]]; then
              LBUFFER="''${LBUFFER#sudo }"
            elif [[ $BUFFER == *\ --\ * ]]; then
              LBUFFER="''${LBUFFER%% -- *} -- sudo ''${LBUFFER#* -- }"
            else
              LBUFFER="sudo $LBUFFER"
            fi
          }
          zle -N sudo-command-line
          bindkey -M emacs '\e\e' sudo-command-line
          bindkey -M vicmd '\e\e' sudo-command-line
          bindkey -M viins '\e\e' sudo-command-line

          p() {
            local dir
            dir=$(find ~/Projects -maxdepth 2 -type d | sed "s|^$HOME/Projects/||" | fzf --header="Select Project")
            if [ -n "$dir" ]; then
              cd "$HOME/Projects/$dir"
            fi
          }

          cppath() {
            if [[ $# -gt 1 ]]; then
              echo "Please provide just one target."
              return
            fi
            local target
            target="$1"
            local fullpath
            fullpath=$(realpath "$target")
            wl-copy "$fullpath"
            echo "Copied $fullpath to the clipboard."
          }

          mksesh() {
            if [[ $# -gt 1 ]]; then
              echo "Please provide just one target."
              return
            fi
            local target
            target="$1"
            mkdir -p "$target"
            zoxide add "$target"
            sesh connect "$target"
          }

          sesh-sessions() {
            {
              exec </dev/tty
              exec <&1
              local session
              session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
              zle reset-prompt >/dev/null 2>&1 || true
              [[ -z "$session" ]] && return
              sesh connect $session
            }
          }

        '';
      in
      lib.mkMerge [
        zstyleConfig
        zvmConfig
        shellIntegrations
        functions
      ];

    profileExtra = ''
      if uwsm check may-start >/dev/null; then
        exec uwsm start hyprland.desktop >/dev/null 2>&1
      fi
    '';
  };

  home = {
    sessionVariables = {
      MANPAGER = "sh -c 'col -bx | bat -l man -p'";
      MANROFFOPT = "-c";
      BAT_THEME = "base16";
      GOPATH = "${config.home.homeDirectory}/.go";
    };

    sessionPath = [
      "${config.home.homeDirectory}/.local/bin"
      "${config.home.homeDirectory}/.go/bin"
    ];

    packages = [ pkgs.zsh-completions ];
  };
}
