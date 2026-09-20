# Shared setup for the bats suites.
#
# Every test gets a throwaway HOME so nothing touches the real one. The repo
# root is exported as DOTFILES so tests can point at files inside it.

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES

setup_fake_home() {
	HOME="$(mktemp -d "${BATS_TEST_TMPDIR}/home.XXXX")"
	export HOME
	unset XDG_CONFIG_HOME XDG_CACHE_HOME XDG_STATE_HOME XDG_DATA_HOME ZDOTDIR
}

# Run the installer non-interactively in the fake HOME.
install_quiet() {
	run bash "$DOTFILES/install.sh" -y "$@"
}

# Start an interactive zsh in the fake HOME and run a command inside it.
# `script` gives it a pseudo-terminal, so zle and completion behave as they
# do in a real terminal. The pty turns \n into \r\n, and macOS `script` echoes
# the two characters "^D" plus two backspaces when its input closes; strip both.
zsh_i() {
	run script -q /dev/null zsh -i -c "$1"
	output=${output//"^D"$'\b\b'/}
	output=${output//$'\r'/}
	output=${output%$'\n'}
	lines=()
	while IFS= read -r line; do lines+=("$line"); done <<< "$output"
}

assert_symlink_to() {
	local link=$1 target=$2
	[ -L "$link" ] || { echo "not a symlink: $link"; return 1; }
	[ "$(readlink "$link")" = "$target" ] || {
		echo "wrong target for $link: $(readlink "$link") (want $target)"
		return 1
	}
}
