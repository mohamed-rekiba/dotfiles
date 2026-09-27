# Interactive shell entry point. Each file in rc.d runs in name order; the
# number prefix is the only thing that decides the order.
#
# Profile a start-up with:  ZSH_PROF=1 zsh -i -c exit
[[ -n $ZSH_PROF ]] && zmodload zsh/zprof

for _rc in $ZDOTDIR/rc.d/*.zsh(N); do
  source $_rc
done
unset _rc

# Machine-local additions. Not tracked.
source_if $ZDOTDIR/local.zsh

if [[ -n $ZSH_PROF ]]; then
  zprof
fi

export PATH=/opt/homebrew/opt/qt@5/bin:$PATH
export LDFLAGS=-L/opt/homebrew/opt/qt@5/lib
export CPPFLAGS=-I/opt/homebrew/opt/qt@5/include
export PKG_CONFIG_PATH=/opt/homebrew/opt/qt@5/lib/pkgconfig
export CMAKE_PREFIX_PATH=/opt/homebrew/opt/qt@5


