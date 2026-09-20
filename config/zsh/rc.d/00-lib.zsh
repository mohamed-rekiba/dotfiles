# Helpers used by the other rc.d files.

# Source FILE if it exists.
source_if() {
  [[ -f $1 ]] && source $1
}

# Evaluate the output of CMD, but from a cached, compiled copy. The cache is
# rebuilt only when the command's binary is newer than it. This turns
# `eval "$(tool init zsh)"` from a subprocess per shell into a file read.
#
#   cache_eval NAME CMD [ARGS...]
cache_eval() {
  local name=$1
  local cache=$XDG_CACHE_HOME/zsh/$name.zsh
  shift
  local bin=$commands[$1]
  if [[ ! -s $cache || $bin -nt $cache ]]; then
    mkdir -p ${cache:h}
    if ! "$@" > $cache; then
      rm -f $cache
      return 1
    fi
    zcompile $cache
  fi
  source $cache
}
