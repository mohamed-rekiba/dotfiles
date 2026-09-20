# Plugins, all from Homebrew. The order is fixed by the plugins themselves:
# fzf-tab needs compinit to have run, and syntax highlighting must be last.
# All of them are zle widgets, so skip them when there is no line editor.
[[ -o zle ]] || return 0

source_if $HOMEBREW_PREFIX/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh
zstyle ':fzf-tab:*' switch-group '<' '>'

# fzf key bindings (Ctrl+R history, Ctrl+T files, Alt+C dirs) and ** completion.
(( $+commands[fzf] )) && cache_eval fzf fzf --zsh

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40   # skip suggestions on long lines
source_if $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

source_if $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
