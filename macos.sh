#!/usr/bin/env bash
#
# macOS defaults. A short list of settings that still exist on macOS 26 and
# that change how the machine behaves for a developer. Run once on a new Mac.
# Some settings need a logout to take effect.
#
# Check a value with:  defaults read <domain> <key>

set -euo pipefail

osascript -e 'tell application "System Preferences" to quit' 2> /dev/null || true

# Keyboard: fast repeat, no autocorrect while typing code.
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Full keyboard access: Tab moves through every control in dialogs.
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Save dialogs open expanded, and save to disk rather than iCloud by default.
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Finder: show extensions, path bar, status bar, POSIX path in the title,
# list view, and stop warning when an extension changes.
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # search the current folder
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# No .DS_Store files on network or USB volumes.
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Dock: hide automatically, no recent apps, smaller tiles.
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock show-recents -bool false
defaults write com.apple.dock tilesize -int 40
defaults write com.apple.dock mru-spaces -bool false   # keep Spaces in a fixed order

# Screenshots: PNG into ~/Screenshots without the window shadow.
mkdir -p "$HOME/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# TextEdit: plain text, UTF-8.
defaults write com.apple.TextEdit RichText -int 0
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4

# Activity Monitor: show all processes, sorted by CPU.
defaults write com.apple.ActivityMonitor ShowCategory -int 0
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

for app in "Activity Monitor" "Dock" "Finder" "SystemUIServer" "TextEdit"; do
	killall "$app" &> /dev/null || true
done
echo "Done. Log out and back in for the keyboard settings to take effect."
