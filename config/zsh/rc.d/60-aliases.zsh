# Aliases. Anything that needs logic lives in 70-functions.zsh.

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias -- -='cd -'
alias dl='cd ~/Downloads'
alias dt='cd ~/Desktop'
alias p='cd ~/projects'

# Listing (colour comes from CLICOLOR, set in 10-env.zsh)
alias l='ls -lF'
alias la='ls -lAF'
alias lsd='ls -lF | grep --color=never "^d"'

alias grep='grep --color=auto'
alias sudo='sudo '            # trailing space: expand aliases after sudo
alias reload='exec zsh'
alias paths='print -l $path'
alias week='date +%V'
alias map='xargs -n1'
alias c="tr -d '\n' | pbcopy"  # trim newlines and copy to clipboard

# Git
alias g='git'
alias ga='git add'
alias gb='git branch'
alias gc='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gl='git pull'
alias glog='git log --oneline --graph --decorate -n 20'
alias gp='git push'
alias gst='git status'
alias gsw='git switch'

# Kubernetes and Docker
alias k='kubectl'
alias kradar='kubectl radar'
alias dcls='docker system prune -af --volumes && docker builder prune -af && docker buildx history rm --all && docker system df'

# Homebrew and macOS updates
alias brewup='brew update && brew upgrade --greedy && brew cleanup && brew doctor'
alias update='sudo softwareupdate -i -a; brewup; gcloud components update'

# Network
alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
alias localip='ipconfig getifaddr en0'
alias flush='dscacheutil -flushcache && killall -HUP mDNSResponder'

# Files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
alias dotclean='dot_clean -m'  # dotclean /Volumes/NAME: merge and remove ._* AppleDouble files
alias mergepdf='gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=_merged.pdf'  # mergepdf a.pdf b.pdf
alias urlencode='python3 -c "import sys, urllib.parse as u; print(u.quote_plus(sys.argv[1]))"'

# Finder and desktop
alias show='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'
alias hide='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
alias hidedesktop='defaults write com.apple.finder CreateDesktop -bool false && killall Finder'
alias showdesktop='defaults write com.apple.finder CreateDesktop -bool true && killall Finder'
alias spotoff='sudo mdutil -a -i off'
alias spoton='sudo mdutil -a -i on'
alias plistbuddy='/usr/libexec/PlistBuddy'
alias afk='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'
alias stfu="osascript -e 'set volume output muted true'"
alias pumpitup="osascript -e 'set volume output volume 100'"

# Fallbacks for GNU names macOS lacks
(( $+commands[hd] ))     || alias hd='hexdump -C'
(( $+commands[md5sum] )) || alias md5sum='md5'
(( $+commands[sha1sum] )) || alias sha1sum='shasum'
