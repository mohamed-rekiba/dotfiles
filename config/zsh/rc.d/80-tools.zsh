# Tool hooks that need more than a PATH entry. Each one is skipped when the
# tool is absent.

# gcloud installed by hand ships its own PATH and completion snippets. The
# Homebrew cask puts its completion into site-functions instead, which
# 40-completion.zsh already covers. The completion snippet calls compdef, so
# it needs the line editor and compinit, same as 40 and 50.
for _sdk in $HOME/google-cloud-sdk $HOMEBREW_PREFIX/share/google-cloud-sdk; do
  if [[ -f $_sdk/path.zsh.inc ]]; then
    source $_sdk/path.zsh.inc
    [[ -o zle ]] && source_if $_sdk/completion.zsh.inc
    break
  fi
done
unset _sdk

# CloudKit CLI
source_if $HOME/.cloudkit-cli/main.sh
