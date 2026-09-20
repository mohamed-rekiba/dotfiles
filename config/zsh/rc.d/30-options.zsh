# Shell options, history and key bindings.

# History: one shared file under XDG_STATE_HOME, no duplicates, timestamps.
HISTFILE=$XDG_STATE_HOME/zsh/history
HISTSIZE=100000
SAVEHIST=$HISTSIZE
[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
setopt EXTENDED_HISTORY        # save timestamp and duration
setopt HIST_IGNORE_ALL_DUPS    # drop older duplicates
setopt HIST_IGNORE_SPACE       # commands starting with a space are not saved
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY             # show the expanded !! before running it
setopt INC_APPEND_HISTORY      # write as you go, not at exit
setopt SHARE_HISTORY           # and read what other shells wrote

# Navigation.
setopt AUTO_CD                 # `dir` alone means `cd dir`
setopt AUTO_PUSHD              # `cd` pushes onto the dir stack
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

setopt INTERACTIVE_COMMENTS    # allow # comments on the command line
setopt NO_BEEP
setopt NO_FLOW_CONTROL         # free Ctrl+S and Ctrl+Q

# Emacs-style line editing, with the keys macOS terminals actually send.
bindkey -e
bindkey '^[[H'    beginning-of-line   # Home
bindkey '^[[F'    end-of-line         # End
bindkey '^[[3~'   delete-char         # Delete
bindkey '^[[1;3C' forward-word        # Alt+Right
bindkey '^[[1;3D' backward-word       # Alt+Left
bindkey '^[[1;5C' forward-word        # Ctrl+Right
bindkey '^[[1;5D' backward-word       # Ctrl+Left

# Up and Down search history for what is already typed.
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search
bindkey '^[[B' down-line-or-beginning-search

# Treat / as a word boundary so Ctrl+W deletes one path segment.
WORDCHARS=${WORDCHARS//\//}
