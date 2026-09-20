# PATH, built once. `typeset -U` drops duplicates, and missing directories are
# harmless, so no existence checks are needed.
typeset -U path fpath

path=(
  $HOME/bin
  $HOME/.local/bin
  $HOMEBREW_PREFIX/bin
  $HOMEBREW_PREFIX/sbin
  $GOPATH/bin
  $KREW_ROOT/bin
  $HOME/.asdf/shims
  $path
)
