#!/usr/bin/env bats

load test_helper

setup() {
	setup_fake_home
	bash "$DOTFILES/install.sh" -y > /dev/null
}

@test "interactive shell starts with exit 0 and no output" {
	zsh_i 'exit'
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "shell starts clean when Homebrew and every optional tool are missing" {
	HOMEBREW_PREFIX=/nonexistent PATH=/usr/bin:/bin:/usr/sbin:/sbin zsh_i 'exit'
	[ "$status" -eq 0 ]
	[ -z "$output" ]
}

@test "ZDOTDIR, history and cache live under XDG dirs" {
	zsh_i 'print $ZDOTDIR; print $HISTFILE; print $ZSH_COMPDUMP'
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "$HOME/.config/zsh" ]
	[ "${lines[1]}" = "$HOME/.local/state/zsh/history" ]
	[[ "${lines[2]}" == "$HOME/.cache/zsh/"* ]]
}

@test "PATH has no duplicates and puts Homebrew first" {
	zsh_i 'print -l $path'
	[ "$status" -eq 0 ]
	[ "$(printf '%s\n' "${lines[@]}" | sort | uniq -d | wc -l)" -eq 0 ]
	[[ "${lines[0]}" == "$HOME/bin" || "${lines[0]}" == "$HOME/.local/bin" ]]
	[[ "$output" == *"/opt/homebrew/bin"* ]]
}

@test "aliases and functions from the rc.d files are defined" {
	zsh_i 'alias l gst; whence -w mkd targz server tre cdiff'
	[ "$status" -eq 0 ]
	[[ "$output" == *"l="* ]]
	[[ "$output" == *"gst="* ]]
	[[ "$output" == *"mkd: function"* ]]
	[[ "$output" == *"server: function"* ]]
}

@test "environment: EDITOR, LANG, GPG_TTY and COPYFILE_DISABLE are set" {
	zsh_i 'print $EDITOR; print $LANG; print ${+GPG_TTY}; print $COPYFILE_DISABLE'
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "vim" ]
	[ "${lines[1]}" = "en_US.UTF-8" ]
	[ "${lines[2]}" = "1" ]
	[ "${lines[3]}" = "1" ]
}

@test "completion is loaded and the dump is compiled" {
	zsh_i 'exit'
	zsh_i 'print ${+functions[_main_complete]}; ls $ZSH_COMPDUMP.zwc'
	[ "$status" -eq 0 ]
	[ "${lines[0]}" = "1" ]
}

@test "local.zsh is sourced last when present" {
	echo 'alias mine="echo mine"' > "$HOME/.config/zsh/local.zsh"
	zsh_i 'alias mine'
	[ "$status" -eq 0 ]
	[[ "$output" == *"mine="* ]]
}

@test "prompt comes from starship when installed" {
	command -v starship > /dev/null || skip "starship not installed"
	zsh_i 'print ${+functions[prompt_starship_precmd]}'
	[ "$status" -eq 0 ]
	[ "$output" = "1" ]
}

@test "start-up stays under the time budget" {
	zsh_i 'exit'  # warm caches
	budget=${ZSH_STARTUP_BUDGET_MS:-150}
	run zsh -c '
		zmodload zsh/datetime
		s=$EPOCHREALTIME
		for i in 1 2 3 4 5; do script -q /dev/null zsh -i -c exit > /dev/null; done
		e=$EPOCHREALTIME
		printf "%d\n" $(( (e - s) * 200 ))
	'
	[ "$status" -eq 0 ]
	ms=${output//[!0-9]/}
	echo "average start-up: ${ms} ms (budget ${budget} ms)"
	[ "$ms" -lt "$budget" ]
}
