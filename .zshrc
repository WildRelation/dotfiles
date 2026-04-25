# === Fastfetch ===
fastfetch
fortune -s -n 120 education science wisdom literature | lolcat

# === Historial ===
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt INC_APPEND_HISTORY hist_ignore_dups hist_ignore_space

# === Autocompletado ===
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# === Plugins ===
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# === Autosuggestions - Catppuccin Mocha ===
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#585b70"

# fast-syntax-highlighting SIEMPRE al final
source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# === Yazi (explorador de archivos) ===
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# === Aliases ===
alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias tree='eza --tree --icons'
alias grep='grep --color=auto'

# === Zoxide (reemplaza cd) ===
eval "$(zoxide init zsh)"

# === FZF (búsqueda difusa) ===
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

# === Starship ===
eval "$(starship init zsh)"

export PATH="$HOME/.local/bin:$PATH"
export EDITOR=nvim
export VISUAL=nvim
export MOZ_USE_XINPUT2=1
