# Environment variables. No subprocesses here.

export LANG=en_US.UTF-8
export EDITOR=vim
export VISUAL=$EDITOR

# less: keep colours, quit if it fits on one screen, do not clear on exit.
export LESS='-R -F -X'
export LESS_TERMCAP_md=$'\e[1;33m'   # bold yellow section titles in man pages

# zsh sets $TTY itself, so gpg gets the terminal without running `tty`.
export GPG_TTY=$TTY

export CLICOLOR=1                    # colour in BSD ls without an alias
export LSCOLORS=BxBxhxDxfxhxhxhxhxcxcx

# Keep tar, cp and rsync from adding ._* AppleDouble entries to archives and
# copies. Finder copies to FAT or SMB volumes still create them; see dotclean.
export COPYFILE_DISABLE=1

export NODE_REPL_HISTORY=$XDG_STATE_HOME/node_repl_history
export PYTHONIOENCODING=UTF-8

export HOMEBREW_NO_ENV_HINTS=1
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

export GOPATH=$HOME/go
export KREW_ROOT=$HOME/.krew

# Claude Code: enable the LSP tool.
export ENABLE_LSP_TOOL=1

# Homebrew prefix. Set it in the environment to point the config at another
# prefix, or at a nonexistent one to test without Homebrew.
if [[ -z $HOMEBREW_PREFIX ]]; then
  if [[ -d /opt/homebrew ]]; then
    HOMEBREW_PREFIX=/opt/homebrew
  else
    HOMEBREW_PREFIX=/usr/local
  fi
fi
export HOMEBREW_PREFIX
