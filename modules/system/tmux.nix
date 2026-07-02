{ pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    terminal = "xterm-256color";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      tmux-floax
      vim-tmux-navigator
      yank
    ];

    extraConfigBeforePlugins = ''
      # Prefix: C-Space
      unbind C-b
      set -g prefix C-Space
      bind C-Space send-prefix

      # Reload
      bind r source-file /etc/tmux.conf \; display "Config reloaded!"

      # Skip kill-pane prompt
      bind x kill-pane

      # Don't detach other clients when destroying session
      set -g detach-on-destroy off

      # Window navigation (Alt+H/L)
      bind -n M-H previous-window
      bind -n M-L next-window

      # Pane settings
      set -g renumber-windows on
      set -g mouse on

      # Terminal overrides for 24-bit color
      set -g terminal-overrides ',xterm-256color:RGB'

      # Status bar: top, two lines, minimal right side
      set -g status-position top
      set -g status-format[1] " "
      set -g status 2
      set -g status-style bg=default,fg=brightblack
      set -g @round-separator-style-prefix fg=colour1,bg=colour19
      set -g @round-separator-style fg=colour16,bg=colour19
      set -g @left-text-style-prefix fg=colour8,bg=colour1
      set -g @left-text-style fg=colour8,bg=colour16
      set -g status-left "#[#{?client_prefix,#{@round-separator-style-prefix},#{@round-separator-style}}]#[#{?client_prefix,#{@left-text-style-prefix},#{@left-text-style}}]󰣇 #S#[#{?client_prefix,#{@round-separator-style-prefix},#{@round-separator-style}}]#[bg=colour19]  "
      set -g status-left-length 30
      set -g status-right "#[fg=colour18]%H:%M  "
      set -g window-status-format "#{window_name}"
      set -g window-status-current-format "#[fg=colour16]#{?window_zoomed_flag,*}#{window_name}"
      set -g window-status-current-style "fg=colour16"
      set -g window-status-bell-style "fg=red,nobold"
      set -g status-justify left

      # Borders
      set -g pane-border-lines single
      set -g pane-border-style fg=colour8
      set -g pane-active-border-style fg=colour16

      # Popup styling
      set -g popup-border-style fg=brightblack
      set -g popup-border-lines rounded

      # Extended keys for kitty
      set -s extended-keys on
      set -as terminal-features 'xterm-kitty:extkeys'

      # Direct resize (no prefix)
      bind -n C-H resize-pane -L 5
      bind -n C-J resize-pane -D 2
      bind -n C-K resize-pane -U 2
      bind -n C-L resize-pane -R 5

      # Copy mode (vi keys)
      bind -n C-y copy-mode
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind -T copy-mode-vi Escape send-keys -X cancel
      # y in copy-mode is handled by tmux-yank plugin (loaded below)

      # Split windows in current directory
      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"

      # Floax (tmux-floax plugin)
      set -g @floax-text-color 'default'
      set -g @floax-bind '-n M-f'

      # Sesh picker (M-s)
      bind -n M-s run-shell "sesh connect \"$(
        sesh list --icons | fzf-tmux -p 80%,70% \
          --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
          --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
          --bind 'tab:down,btab:up' \
          --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
          --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
          --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
          --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
          --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
          --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
          --preview-window 'right:55%' \
          --preview 'sesh preview {}'
      )\""

      # Sesh last (M-l)
      bind -n M-l run-shell "sesh last"

      # Lazygit popup (M-g)
      bind -n M-g popup -d '#{pane_current_path}' -w80% -h80% -E 'lazygit'
    '';
  };
}
