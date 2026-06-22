{ pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    autocd = true;
    enableCompletion = true;
    defaultKeymap = "viins";

    # Nix-managed plugins (sourced from store, no runtime plugin manager).
    plugins = [
      {
        name = "zsh-fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    history = {
      path = "$HOME/.zsh_history";
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      findNoDups = true;
      saveNoDups = true;
      share = true;
      append = true;
    };

    shellAliases = {
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
      zconf = "nvim $HOME/.zshrc";
      kittyconf = "nvim $HOME/.config/kitty/kitty.conf";
      nvconf = "nvim $HOME/.config/nvim";
      rsy = "rsync -ahP";
      nvims = "sudoedit";
      mkdir = "mkdir -p";
      rf = "rm -rf";
      lsk = "lsblk";
      espidf = "source $HOME/.esp/esp-idf/export.sh &> /dev/null";
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";
      mount = "sudo mount";
      umount = "sudo umount";
      mux = "tmuxinator";
    };

    shellGlobalAliases = {
      "-h" = "-h 2>&1 | bat --language=help --style=plain";
      "--help" = "--help 2>&1 | bat --language=help --style=plain";
      NE = "2>/dev/null";
      NS = ">/dev/null";
      NO = ">/dev/null 2>&1";
      C = "| wl-copy";
    };

    setOptions = [ "globdots" "extendedglob" ];

    autosuggestion.enable = true;

    syntaxHighlighting.enable = true;

    initContent = lib.mkMerge [
      # Early: tmux auto-attach (500)
      (lib.mkOrder 500 ''
        if [ -z "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
          tmux new-session -A -s main 2>/dev/null
        fi
      '')

      # Before plugin source at 900: zsh-vi-mode config hook
      (lib.mkOrder 800 ''
        function zvm_config() {
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
      '')

      # After plugins: completion zstyles, zvm_after_init (1000)
      (lib.mkOrder 1000 ''
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-Z}'
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
        zstyle ':completion:*' menu no
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -A -1 --color=always $realpath'
        zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -A -1 --color=always $realpath'
        zstyle ':fzf-tab:complete:git-(commit|add|diff|restore):*' fzf-preview \
          'git diff $realpath | delta --syntax-theme=base16'

        function zvm_after_init() {
          bindkey -M viins '^p' history-search-backward
          bindkey -M viins '^n' history-search-forward
          bindkey -M viins ' ' magic-space
          bindkey -M viins '^R' fzf-history-widget
          zle -N sesh-sessions
          bindkey -M vicmd '^s' sesh-sessions
          bindkey -M viins '^s' sesh-sessions
        }

        alias sudo='sudo '
      '')

      # Late: custom functions, env vars, stty (1500)
      (lib.mkOrder 1500 ''
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
          local target fullpath
          target="$1"
          fullpath=$(realpath "$target")
          wl-copy "$fullpath"
          echo "Copied $fullpath to the clipboard."
        }

        mksesh() {
          if [[ $# -gt 1 ]]; then
            echo "Please provide just one target."
            return
          fi
          local target="$1"
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
            sesh connect "$session"
          }
        }

        y() {
          local tmp cwd
          tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
          yazi "$@" --cwd-file="$tmp"
          IFS= read -r -d '''' cwd <"$tmp"
          [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
          rm -f -- "$tmp"
        }

        export _PR_AI_DISABLE=1
        stty -ixon
      '')
    ];
  };

  programs.zsh.profileExtra = ''
    if uwsm check may-start; then
      exec uwsm start hyprland-uwsm.desktop
    fi
  '';
}
