#!/usr/bin/env bats

load test_helper

@test "shellcheck passes on the bash scripts" {
	run shellcheck "$DOTFILES"/install.sh "$DOTFILES"/macos.sh "$DOTFILES"/tests/test_helper.bash
	[ "$status" -eq 0 ]
}

@test "every zsh file parses" {
	local f
	while IFS= read -r f; do
		run zsh -n "$f"
		[ "$status" -eq 0 ] || { echo "syntax error in $f: $output"; return 1; }
	done < <(find "$DOTFILES/home" "$DOTFILES/config/zsh" -type f \( -name '*.zsh' -o -name '.zsh*' \))
}

@test "json config files are valid" {
	local f
	while IFS= read -r f; do
		run python3 -m json.tool "$f"
		[ "$status" -eq 0 ] || { echo "invalid json: $f"; return 1; }
	done < <(find "$DOTFILES/config" "$DOTFILES/claude" -name '*.json')
}

@test "markdown files pass markdownlint" {
	command -v markdownlint > /dev/null || skip "markdownlint not installed"
	run markdownlint "$DOTFILES"/README.md "$DOTFILES"/LICENSE.md
	[ "$status" -eq 0 ]
}

@test "starship config is valid TOML" {
	run starship config --help
	[ "$status" -eq 0 ] || skip "starship not installed"
	run env STARSHIP_CONFIG="$DOTFILES/config/starship.toml" starship print-config
	[ "$status" -eq 0 ]
}
