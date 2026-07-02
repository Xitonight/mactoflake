{ pkgs, ... }:

{
  programs = {
    sesh = {
      enableAlias = true;
      enableTmuxIntegration = true;
      tmuxKey = "M-s";
    };
    tmux = {
      enable = true;
      baseIndex = 1;
      keyMode = "vi";
      terminal = "xterm-256color";
      mouse = true;
      disableConfirmationPrompt = true;
      prefix = "C-Space";
      plugins = with pkgs.tmuxPlugins; [
        sensible
        {
          plugin = tmux-floax;
          extraConfig = ''
            # Floax (tmux-floax plugin)
            set -g @floax-text-color 'default'
            set -g @floax-bind '-n M-f'
          '';
        }
        vim-tmux-navigator
        yank
      ];

      extraConfig = ''
        # Extended keys for kitty
        set -s extended-keys on
        set -as terminal-features 'xterm-kitty:extkeys'

        set -g renumber-windows on
        set -g terminal-overrides ',xterm-256color:RGB' # Terminal overrides for 24-bit color
        set -g detach-on-destroy off # Don't detach other clients when destroying session

        # Popup styling
        set -g popup-border-style fg=brightblack
        set -g popup-border-lines rounded

        # Status bar: top, two lines, minimal right side
        set -g status-position top
        set -g status-format[1] " "
        set -g status 2
        set -g status-style bg=default,fg=brightblack
        set -g @round-separator-style-prefix fg=colour1,bg=colour19
        set -g @round-separator-style fg=colour16,bg=colour19
        set -g @left-text-style-prefix fg=colour8,bg=colour1
        set -g @left-text-style fg=colour8,bg=colour16
        set -g status-left "#[#{?client_prefix,#{@round-separator-style-prefix},#{@round-separator-style}}]#[#{?client_prefix,#{@left-text-style-prefix},#{@left-text-style}}]󰣇 #S#[#{?client_prefix,#{@round-separator-style-prefix},#{@round-separator-style}}]#[bg=colour19]  "
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

        bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"

        # Window navigation (Alt+H/L)
        bind -n M-H previous-window
        bind -n M-L next-window



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

        # Split windows in current directory
        bind '"' split-window -v -c "#{pane_current_path}"
        bind % split-window -h -c "#{pane_current_path}"

        # Sesh last (M-l)
        bind -n M-l run-shell "sesh last"

        # Lazygit popup (M-g)
        bind -n M-g popup -d '#{pane_current_path}' -w80% -h80% -E 'lazygit'
      '';
    };
  };
}
