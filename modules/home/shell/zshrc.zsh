# Auto-attach to (or create) a tmux session on a local (non-SSH) login.
if [ -z "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
  tmux new-session -A -s main 2>/dev/null
fi

# Bootstrap the zinit plugin manager.
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
  mkdir -p "$(dirname "$ZINIT_HOME")"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "$ZINIT_HOME/zinit.zsh"

zinit light zsh-users/zsh-completions
autoload -U compinit && compinit
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

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
zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode
zinit snippet OMZP::sudo
zinit cdreplay -q

# Completion tweaks
setopt globdots
setopt extendedglob
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-Z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -A -1 --color=always $realpath'
zstyle ':fzf-tab:complete:ls:*' fzf-preview 'eza -A -1 --color=always $realpath'
zstyle ':fzf-tab:complete:git-(commit|add|diff|restore):*' fzf-preview \
  'git diff $realpath | delta --syntax-theme=base16'

# Aliases
alias l='eza -lh --icons=auto'
alias ls='eza --icons=auto'
alias la='eza -A --icons=auto'
alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
alias ld='eza -lhD --icons=auto'
alias lt='eza --icons=auto --tree'
alias lta='eza -a --icons=auto --tree'
alias ltt='eza --icons=auto --tree --level 1'
alias ltta='eza -a --icons=auto --tree --level 1'

alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

alias v='nvim'
alias vim='nvim'
alias j='just'
alias open='xdg-open'

alias zconf='nvim "$HOME/.zshrc"'
alias kittyconf='nvim "$HOME/.config/kitty/kitty.conf"'
alias nvconf='nvim "$HOME/.config/nvim"'

alias rsy='rsync -ahP'
alias nvims='sudoedit'
alias mkdir='mkdir -p'
alias rf='rm -rf'
alias lsk='lsblk'

alias espidf='source "$HOME/.esp/esp-idf/export.sh" &> /dev/null'

alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

alias mount='sudo mount'
alias umount='sudo umount'

alias mux='tmuxinator'

alias -g NE='2>/dev/null'
alias -g NS='>/dev/null'
alias -g NO='>/dev/null 2>&1'
alias -g C='| wl-copy'

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

# Shell integrations
source <(fzf --zsh)
eval "$(zoxide init --cmd cd zsh)"
eval "$(pay-respects zsh)"
export _PR_AI_DISABLE=1

function zvm_after_init() {
  bindkey -M viins '^p' history-search-backward
  bindkey -M viins '^n' history-search-forward
  bindkey -M viins ' ' magic-space
  bindkey -M viins '^R' fzf-history-widget

  zle -N sesh-sessions
  bindkey -M vicmd '^s' sesh-sessions
  bindkey -M viins '^s' sesh-sessions
}

y() {
  local tmp cwd
  tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

# Disable start/stop output control (XON/XOFF) so ctrl-s / ctrl-q are free.
stty -ixon
