#!/usr/bin/env bash
#
# Symlink the dotfiles into place.
#
#   home/<file>    -> ~/<file>
#   config/<path>  -> ${XDG_CONFIG_HOME:-~/.config}/<path>
#   claude/        -> ~/.claude (*.md linked, settings.json copied once)
#
# Every file is linked on its own, so untracked files can sit next to tracked
# ones in the same directory. A real file in the way is moved to
# ~/.dotfiles-backup/<timestamp>/ first. Safe to re-run at any time.
#
# Usage: install.sh [-y]
#   -y   Non-interactive: never prompt. Prints a reminder instead of asking
#        for the git identity.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
YES=0

usage() {
	cat <<-'EOF'
	Usage: install.sh [-y]

	Symlink the dotfiles into ~ and ~/.config, back up anything in the way to
	~/.dotfiles-backup/, and ask for the git identity on the first run.

	  -y   Never prompt. Prints a reminder instead of asking for the identity.
	EOF
}

for arg in "$@"; do
	case "$arg" in
		-y|--yes) YES=1 ;;
		-h|--help) usage; exit 0 ;;
		*) echo "unknown option: $arg" >&2; usage >&2; exit 2 ;;
	esac
done

log() { printf '%s\n' "$*"; }

# Make DST a symlink to SRC. Anything else at DST, a file or a link to
# somewhere else, is moved to the backup dir first.
link() {
	local src=$1 dst=$2 rel
	if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
		return
	fi
	mkdir -p "$(dirname "$dst")"
	if [ -e "$dst" ] || [ -L "$dst" ]; then
		rel=${dst#"$HOME"/}
		rel=${rel#/}
		mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
		mv "$dst" "$BACKUP_DIR/$rel"
		log "backup $dst -> $BACKUP_DIR/$rel"
	fi
	ln -sfn "$src" "$dst"
	log "link   $dst -> $src"
}

# Link every file under SRC_ROOT to the same relative path under DST_ROOT.
link_tree() {
	local src_root=$1 dst_root=$2 f
	while IFS= read -r -d '' f; do
		link "$f" "$dst_root/${f#"$src_root"/}"
	done < <(find "$src_root" -type f -print0)
}

# Remove symlinks under ROOT (to DEPTH levels) that point into the repo but
# whose target no longer exists. Links to anything else are left alone.
prune() {
	local root=$1 depth=$2 l target
	[ -d "$root" ] || return 0
	while IFS= read -r -d '' l; do
		target=$(readlink "$l")
		if [[ $target == "$DOTFILES"/* ]] && [ ! -e "$target" ]; then
			rm "$l"
			log "prune  $l"
		fi
	done < <(find "$root" -maxdepth "$depth" -type l -print0)
}

install_links() {
	local d
	link_tree "$DOTFILES/home" "$HOME"
	link_tree "$DOTFILES/config" "$CONFIG_HOME"

	prune "$HOME" 1
	prune "$CONFIG_HOME" 1
	for d in "$DOTFILES"/config/*/; do
		prune "$CONFIG_HOME/$(basename "$d")" 10
	done
}

# The Markdown files are safe to link. settings.json is only seeded, because
# Claude Code writes machine-local permission grants into the live copy.
install_claude() {
	mkdir -p "$HOME/.claude"
	link "$DOTFILES/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
	link "$DOTFILES/claude/CODING_STANDARDS.md" "$HOME/.claude/CODING_STANDARDS.md"
	if [ ! -e "$HOME/.claude/settings.json" ]; then
		cp "$DOTFILES/claude/settings.json" "$HOME/.claude/settings.json"
		log "copy   $HOME/.claude/settings.json (seeded once, edit freely)"
	fi
}

# Copy OLD to NEW once, when OLD exists and NEW does not.
migrate() {
	local old=$1 new=$2
	if [ -f "$old" ] && [ ! -f "$new" ]; then
		mkdir -p "$(dirname "$new")"
		cp "$old" "$new"
		log "copy   $old -> $new"
	fi
}

# Files the previous layout kept in the home directory. Each is carried over
# the first time so nothing is lost: shell history, git identity, and the
# machine-local shell additions.
migrate_old_layout() {
	migrate "$HOME/.zsh_history" "$STATE_HOME/zsh/history"
	migrate "$HOME/.gitconfig.local" "$CONFIG_HOME/git/local"
	migrate "$HOME/.extra" "$CONFIG_HOME/zsh/local.zsh"
}

identity_reminder() {
	log "Git identity is not set. Run:"
	log "  git config --file $1 user.name 'Your Name'"
	log "  git config --file $1 user.email 'you@example.com'"
}

# Identity lives in a file that git/config includes and that is never tracked.
# Without a terminal on stdin the prompt cannot be answered, so fall back to
# the reminder rather than fail.
setup_git_identity() {
	local file=$CONFIG_HOME/git/local name email input
	name=$(git config --file "$file" user.name 2> /dev/null || true)
	email=$(git config --file "$file" user.email 2> /dev/null || true)
	if [ -n "$name" ] && [ -n "$email" ]; then
		return
	fi
	if [ "$YES" = 1 ]; then
		identity_reminder "$file"
		return
	fi
	echo ""
	echo "Git identity for commits (stored in $file):"
	if ! read -r -p "  user.name  [${name:-none}]: " input; then
		echo ""
		identity_reminder "$file"
		return
	fi
	if [ -n "$input" ]; then
		name=$input
	fi
	if ! read -r -p "  user.email [${email:-none}]: " input; then
		echo ""
		identity_reminder "$file"
		return
	fi
	if [ -n "$input" ]; then
		email=$input
	fi
	mkdir -p "$(dirname "$file")"
	if [ -n "$name" ]; then
		git config --file "$file" user.name "$name"
	fi
	if [ -n "$email" ]; then
		git config --file "$file" user.email "$email"
	fi
}

install_links
install_claude
migrate_old_layout
setup_git_identity
log "Done. Open a new shell."
