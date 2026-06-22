{ ... }:

{
  programs.fish = {
    enable = true;

    # Command abbreviations -- the idiomatic fish way to mirror the zsh alias
    # set. They expand inline as you type, showing the real command.
    shellAbbrs = {
      # eza
      l = "eza -lh --icons=auto";
      ls = "eza --icons=auto";
      la = "eza -A --icons=auto";
      ll = "eza -lha --icons=auto --sort=name --group-directories-first";
      ld = "eza -lhD --icons=auto";
      lt = "eza --icons=auto --tree";
      lta = "eza -a --icons=auto --tree";
      ltt = "eza --icons=auto --tree --level 1";
      ltta = "eza -a --icons=auto --tree --level 1";

      # editor / launchers
      v = "nvim";
      vim = "nvim";
      j = "just";
      open = "xdg-open";

      # config editors (parity with zsh; on NixOS these targets are read-only
      # store symlinks, same limitation as under zsh -- kept for parity)
      zconf = ''nvim "$HOME/.zshrc"'';
      kittyconf = ''nvim "$HOME/.config/kitty/kitty.conf"'';
      nvconf = ''nvim "$HOME/.config/nvim"'';

      # misc
      rsy = "rsync -ahP";
      nvims = "sudoedit";
      mkdir = "mkdir -p";
      rf = "rm -rf";
      lsk = "lsblk";
      mux = "tmuxinator";
      # ESP-IDF ships a fish-specific exporter (manual install, Phase 5).
      espidf = ''source "$HOME/.esp/esp-idf/export.fish" >/dev/null 2>&1'';

      # directory navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      ".3" = "cd ../../..";
      ".4" = "cd ../../../..";
      ".5" = "cd ../../../../..";

      # privileged
      mount = "sudo mount";
      umount = "sudo umount";
    };

    functions = {
      # fzf-jump into ~/Projects
      p = ''
        set dir (find ~/Projects -maxdepth 2 -type d | sed "s|^$HOME/Projects/||" | fzf --header="Select Project")
        if test -n "$dir"
            cd "$HOME/Projects/$dir"
        end
      '';

      # copy the absolute path of a target to the clipboard
      cppath = ''
        if test (count $argv) -gt 1
            echo "Please provide just one target."
            return
        end
        set target $argv[1]
        set fullpath (realpath "$target")
        wl-copy "$fullpath"
        echo "Copied $fullpath to the clipboard."
      '';

      # make + register + attach a sesh session
      mksesh = ''
        if test (count $argv) -gt 1
            echo "Please provide just one target."
            return
        end
        set target $argv[1]
        mkdir -p "$target"
        zoxide add "$target"
        sesh connect "$target"
      '';

      # sesh picker (bound to ^s in vi insert/normal modes below)
      "sesh-sessions" = ''
        set session (sesh list -t -c | fzf --height=40% --reverse --border-label=' sesh ' --border --prompt='⚡  ')
        if test -n "$session"
            sesh connect "$session"
        end
      '';

      # yazi wrapper that cd's into the dir yazi was in on exit
      y = ''
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and test -n "$cwd"; and test "$cwd" != "$PWD"
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
      '';
    };

    interactiveShellInit = ''
      set -g fish_greeting ""

      # Auto-attach (or create) a tmux session on a local (non-SSH) login.
      if test -z "$SSH_CONNECTION"; and test -z "$TMUX"
          tmux new-session -A -s main 2>/dev/null
      end

      # Free up ctrl-s / ctrl-q (disable XON/XOFF flow control).
      stty -ixon

      # vi mode + cursors (mirrors zsh-vi-mode: normal=underline, insert=beam,
      # visual=block, all blinking).
      set -g fish_cursor_default     underscore blink
      set -g fish_cursor_insert      line blink
      set -g fish_cursor_replace_one underscore blink
      set -g fish_cursor_visual      block blink
      fish_vi_key_bindings

      # Misc
      set -gx _PR_AI_DISABLE 1

      # vi-mode key binds (match zsh: ^p/^n history search, ^r fzf history,
      # ^s sesh picker). Must come after fish_vi_key_bindings and after fzf is
      # sourced (fzf provides fzf-history-widget).
      bind -M insert \cp history-search-backward
      bind -M insert \cn history-search-forward
      bind -M insert \cr fzf-history-widget
      bind -M insert \cs sesh-sessions
      bind -M default \cs sesh-sessions

      # "Global" abbreviations (expand anywhere on the line) -- zsh
      # "alias -g" parity. Requires fish >= 3.6 for --position anywhere.
      abbr -a --position anywhere -- -h '-h 2>&1 | bat --language=help --style=plain'
      abbr -a --position anywhere -- --help '--help 2>&1 | bat --language=help --style=plain'
      abbr -a --position anywhere C '| wl-copy'
      abbr -a --position anywhere NE '2>/dev/null'
      abbr -a --position anywhere NS '>/dev/null'
      abbr -a --position anywhere NO '>/dev/null 2>&1'
    '';
  };
}
