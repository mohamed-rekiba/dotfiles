#!/usr/bin/env bats

load test_helper

setup() {
	setup_fake_home
}

@test "links home/ files into HOME and config/ files into ~/.config" {
	install_quiet
	[ "$status" -eq 0 ]
	assert_symlink_to "$HOME/.zshenv" "$DOTFILES/home/.zshenv"
	assert_symlink_to "$HOME/.config/zsh/.zshrc" "$DOTFILES/config/zsh/.zshrc"
	assert_symlink_to "$HOME/.config/git/config" "$DOTFILES/config/git/config"
	assert_symlink_to "$HOME/.config/starship.toml" "$DOTFILES/config/starship.toml"
}

@test "respects XDG_CONFIG_HOME" {
	export XDG_CONFIG_HOME="$HOME/xdg"
	install_quiet
	[ "$status" -eq 0 ]
	assert_symlink_to "$HOME/xdg/zsh/.zshrc" "$DOTFILES/config/zsh/.zshrc"
	[ ! -e "$HOME/.config/zsh/.zshrc" ]
}

@test "backs up an existing regular file before linking over it" {
	mkdir -p "$HOME/.config/git"
	echo "mine" > "$HOME/.config/git/config"
	install_quiet
	[ "$status" -eq 0 ]
	assert_symlink_to "$HOME/.config/git/config" "$DOTFILES/config/git/config"
	backup=$(find "$HOME/.dotfiles-backup" -type f -path '*/.config/git/config')
	[ -n "$backup" ]
	[ "$(cat "$backup")" = "mine" ]
}

@test "backs up a symlink that points somewhere else" {
	mkdir -p "$HOME/.config/git"
	ln -s /somewhere/else "$HOME/.config/git/config"
	install_quiet
	[ "$status" -eq 0 ]
	assert_symlink_to "$HOME/.config/git/config" "$DOTFILES/config/git/config"
	backup=$(find "$HOME/.dotfiles-backup" -type l -path '*/.config/git/config')
	[ "$(readlink "$backup")" = "/somewhere/else" ]
}

@test "second run changes nothing and creates no backup" {
	install_quiet
	install_quiet
	[ "$status" -eq 0 ]
	[ ! -d "$HOME/.dotfiles-backup" ]
	[[ "$output" != *"link "* ]]
	[[ "$output" != *"backup "* ]]
}

@test "removes dangling links that point into the repo, keeps other links" {
	install_quiet
	ln -s "$DOTFILES/config/zsh/rc.d/99-gone.zsh" "$HOME/.config/zsh/rc.d/99-gone.zsh"
	ln -s /nonexistent/elsewhere "$HOME/.config/zsh/rc.d/foreign.zsh"
	install_quiet
	[ "$status" -eq 0 ]
	[ ! -L "$HOME/.config/zsh/rc.d/99-gone.zsh" ]
	[ -L "$HOME/.config/zsh/rc.d/foreign.zsh" ]
}

@test "links the claude Markdown files but copies settings.json only once" {
	install_quiet
	assert_symlink_to "$HOME/.claude/CLAUDE.md" "$DOTFILES/claude/CLAUDE.md"
	assert_symlink_to "$HOME/.claude/CODING_STANDARDS.md" "$DOTFILES/claude/CODING_STANDARDS.md"
	[ -f "$HOME/.claude/settings.json" ]
	[ ! -L "$HOME/.claude/settings.json" ]
	echo '{"mine":1}' > "$HOME/.claude/settings.json"
	install_quiet
	[ "$(cat "$HOME/.claude/settings.json")" = '{"mine":1}' ]
}

@test "migrates ~/.zsh_history into the state dir when no history exists there" {
	echo ": 1:0;echo old" > "$HOME/.zsh_history"
	install_quiet
	[ "$status" -eq 0 ]
	[ -f "$HOME/.local/state/zsh/history" ]
	grep -q "echo old" "$HOME/.local/state/zsh/history"
}

@test "migrates ~/.gitconfig.local and ~/.extra from the old layout" {
	git config --file "$HOME/.gitconfig.local" user.name "Old Name"
	git config --file "$HOME/.gitconfig.local" user.email "old@example.com"
	echo 'alias fromextra="echo hi"' > "$HOME/.extra"
	install_quiet
	[ "$status" -eq 0 ]
	[ "$(git config user.name)" = "Old Name" ]
	grep -q fromextra "$HOME/.config/zsh/local.zsh"
	[[ "$output" != *"Git identity is not set"* ]]
}

@test "interactive run with empty answers exits 0 and writes nothing" {
	run bash -c "printf '\n\n' | bash '$DOTFILES/install.sh'"
	[ "$status" -eq 0 ]
	[[ "$output" == *"Done."* ]]
	[ ! -f "$HOME/.config/git/local" ]
}

@test "interactive run with closed stdin falls back to the reminder" {
	run bash -c "bash '$DOTFILES/install.sh' < /dev/null"
	[ "$status" -eq 0 ]
	[[ "$output" == *"Git identity is not set"* ]]
	[[ "$output" == *"Done."* ]]
}

@test "-y prints a git identity reminder and writes nothing" {
	install_quiet
	[ "$status" -eq 0 ]
	[[ "$output" == *"Git identity"* ]]
	[ ! -f "$HOME/.config/git/local" ]
}

@test "interactive run asks for the git identity and git resolves it" {
	run bash -c "printf 'Test Person\ntest@example.com\n' | bash '$DOTFILES/install.sh'"
	[ "$status" -eq 0 ]
	[ "$(git config user.name)" = "Test Person" ]
	[ "$(git config user.email)" = "test@example.com" ]
	[ ! -L "$HOME/.config/git/local" ]
}

@test "interactive run skips the prompt when the identity is already set" {
	mkdir -p "$HOME/.config/git"
	git config --file "$HOME/.config/git/local" user.name "Set Already"
	git config --file "$HOME/.config/git/local" user.email "set@example.com"
	run bash -c "bash '$DOTFILES/install.sh' < /dev/null"
	[ "$status" -eq 0 ]
	[[ "$output" != *"user.name"* ]]
	[ "$(git config user.name)" = "Set Already" ]
}
