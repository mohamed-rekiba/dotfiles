# Completion. One compinit, with a dump that is trusted for a day and kept
# compiled. Every fpath entry uses the (N/) qualifier so only directories that
# exist are added.
#
# Without a terminal (for example `zsh -ic cmd` from a script) there is no
# line editor, so completion has nothing to attach to. Skip it quietly.
[[ -o zle ]] || return 0

fpath=(
  $HOMEBREW_PREFIX/share/zsh/site-functions(N/)   # Homebrew formulae: aws, kubectl, gh, ...
  $HOMEBREW_PREFIX/share/zsh-completions(N/)
  $HOME/.docker/completions(N/)
  $fpath
)

autoload -Uz compinit compaudit
ZSH_COMPDUMP=$XDG_CACHE_HOME/zsh/compdump-$ZSH_VERSION
[[ -d ${ZSH_COMPDUMP:h} ]] || mkdir -p ${ZSH_COMPDUMP:h}

# -C skips the security scan of fpath and trusts the dump. Do the full run
# once a day, or when the dump is missing. On the full run, a group-writable
# directory in fpath would make compinit stop and ask; warn and skip it
# instead. `make brew` fixes the usual cause, Homebrew's share directory.
() {
  setopt localoptions extendedglob
  if [[ -n $ZSH_COMPDUMP(#qN.mh-24) ]]; then
    compinit -C -d $ZSH_COMPDUMP
  elif compaudit &> /dev/null; then
    compinit -d $ZSH_COMPDUMP
  else
    print -u2 "zsh: insecure completion directories, skipped them. Fix with: chmod go-w $HOMEBREW_PREFIX/share"
    compinit -i -d $ZSH_COMPDUMP
  fi
}
[[ $ZSH_COMPDUMP.zwc -nt $ZSH_COMPDUMP ]] || zcompile $ZSH_COMPDUMP

zstyle ':completion:*' menu no                      # fzf-tab draws the menu
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $XDG_CACHE_HOME/zsh/compcache
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'   # case-insensitive, partial words
zstyle ':completion:*' list-colors ''                # default colours for file names
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' squeeze-slashes yes
