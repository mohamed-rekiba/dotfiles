# Read by every zsh, interactive or not. Keep it to the variables that decide
# where the rest of the configuration lives.
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
