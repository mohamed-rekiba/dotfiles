# Prompt. Starship when installed, a one-line fallback otherwise.

if (( $+commands[starship] )); then
  cache_eval starship starship init zsh --print-full-init
else
  setopt PROMPT_SUBST
  PROMPT='%(?.%F{cyan}.%F{red})➜%f %F{cyan}%1~%f '
fi
