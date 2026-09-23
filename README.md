# dotfiles

macOS shell configuration for one developer who works with Go, Kubernetes,
AWS, Docker and Claude Code. Plain zsh, no framework, every file under
`~/.config`, and a new Mac ready with three commands.

The design goal is a shell that starts fast and never breaks: a missing tool
is skipped, a file in the way is backed up, and a second install run changes
nothing.

**Warning:** these are personal settings. Read the files and remove what you
do not want before you install them.

## Status

Works on macOS 26 with zsh 5.9 and Homebrew on Apple silicon. GitHub Actions
runs the test suite on a macOS runner on every push.

Last local run of `make test`, 2026-09-21: 29 tests, 29 pass.

| What the tests prove | Result |
| --- | --- |
| Interactive shell start, average of 5 runs | 71 ms, budget 150 ms |
| Start with Homebrew and every optional tool missing | exit 0, no output |
| Install into an empty home, then again | idempotent, no backup on run 2 |
| A file or foreign symlink in the way | moved to `~/.dotfiles-backup/` |
| Old `~/.zsh_history`, `~/.gitconfig.local`, `~/.extra` | carried over once |
| shellcheck, `zsh -n`, JSON, TOML, markdownlint | clean |

Not covered by tests: `make brew` and `make macos` on a clean machine. See
[Limitations](#limitations).

## Install

Homebrew must be installed first. The three commands, in order:

```bash
git clone https://github.com/mohamed-rekiba/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make brew && make install && make macos
```

What each one does:

- `make brew` installs the `Brewfile` with `brew bundle`, then removes group
  write from Homebrew's `share` directory. Without that fix zsh treats the
  completions installed there as insecure and skips them.
- `make install` symlinks the files into `~` and `~/.config`. Anything in
  the way is moved to `~/.dotfiles-backup/<timestamp>/` first. On the first
  run it asks for your git name and email.
- `make macos` writes system, Finder, Dock and keyboard preferences with
  `defaults` and restarts Finder and the Dock. Read `macos.sh` first. Skip
  it if you do not want your preferences changed.

To update, pull and run `make install` again. The files are links, so an
edit in `~/.config` is already an edit in the repository.

### Local settings

Two untracked files hold what belongs to the machine, not the repository.
The installer creates them and never overwrites them.

| File | Holds |
| --- | --- |
| `~/.config/git/local` | `user.name`, `user.email`, and any git override. |
| `~/.config/zsh/local.zsh` | Aliases, exports or secrets. Sourced last. |

Claude Code is the one exception to linking: `~/.claude/CLAUDE.md` and
`~/.claude/CODING_STANDARDS.md` are links, but `~/.claude/settings.json` is
copied once, because Claude Code writes machine-local permission grants into
it.

### Defaults you may want to change

These are deliberate choices. Each one is a single line in a local file.

- Git signs every commit and tag. Without a GPG key every commit fails.
  Turn it off with `git config --file ~/.config/git/local commit.gpgsign false`.
- `git pull` rebases instead of merging (`pull.rebase`). Override it the
  same way.
- The prompt shows only the current directory name, not the path.
  Change `truncation_length` in `config/starship.toml`.

## How it is built

### Layout

| Repository path | Installed to | Purpose |
| --- | --- | --- |
| `home/.zshenv` | `~/.zshenv` | Sets `ZDOTDIR` and the XDG variables. |
| `home/.editorconfig` | `~/.editorconfig` | Indentation defaults for editors. |
| `config/zsh/` | `~/.config/zsh/` | `.zshrc` and `rc.d/`, one file per concern. |
| `config/starship.toml` | `~/.config/` | Prompt: arrow, directory, git branch and state. |
| `config/git/` | `~/.config/git/` | Git config and global ignore list. |
| `config/tmux/` | `~/.config/tmux/` | tmux, prefix `Ctrl+A`. |
| `config/vim/` | `~/.config/vim/` | Vim 9.1 with Solarized. |
| `config/ccstatusline/` | `~/.config/ccstatusline/` | Claude Code status line. |
| `claude/` | `~/.claude/` | Claude Code instructions, coding standards, and seed settings. |
| `install.sh` | | The symlink installer. `install.sh -y` never prompts. |
| `Brewfile` | | Packages for `brew bundle`. |
| `macos.sh` | | macOS defaults. |
| `tests/` | | bats suites: install, shell start-up, lint. |

### Shell start-up

`~/.zshenv` sets `ZDOTDIR=~/.config/zsh`, so zsh reads `.zshrc` from there.
`.zshrc` sources every file in `rc.d/` in name order, then `local.zsh`.

| File | Does |
| --- | --- |
| `00-lib.zsh` | `source_if` and `cache_eval`, used by the files below. |
| `10-env.zsh` | Environment variables. No subprocesses. |
| `20-path.zsh` | PATH as one array with duplicates removed. |
| `30-options.zsh` | History under `~/.local/state`, options, key bindings. |
| `40-completion.zsh` | `fpath`, one compinit with a daily cache, zstyles. |
| `50-plugins.zsh` | fzf-tab, fzf bindings, autosuggestions, syntax highlighting. |
| `60-aliases.zsh` | Aliases, including short git aliases. |
| `70-functions.zsh` | `mkd`, `targz`, `server`, `tre`, `cdiff` and others. |
| `80-tools.zsh` | Hooks for gcloud and other tools that need more than PATH. |
| `90-prompt.zsh` | Starship, or a one-line fallback prompt. |

Four rules keep start-up fast:

- No subprocess runs on a warm start. `cache_eval` keeps the output of
  `starship init` and `fzf --zsh` in `~/.cache/zsh`, compiled, and rebuilds
  it only when the binary changes.
- `compinit` runs once per shell. It trusts its dump for a day, then does
  one full scan and recompiles the dump.
- Plugins come from Homebrew and are sourced from fixed paths. There is no
  plugin manager.
- Every optional tool is guarded. A missing one is skipped, not an error.

Profile a start-up with:

```bash
ZSH_PROF=1 zsh -i -c exit
```

### Tests

The suite needs `bats-core`, `shellcheck` and `starship`, all in the
`Brewfile`. `markdownlint-cli` is optional; its test skips when absent.

```bash
make test
```

Each test gets a throwaway `HOME`, runs the installer into it, and starts
zsh under a pseudo-terminal so completion and plugins load as they do for a
user. `ZSH_STARTUP_BUDGET_MS` overrides the start-up budget of 150 ms.

## Limitations

- `make brew` and `make macos` have not been run end to end on a clean
  machine. The Brewfile was checked against an existing installation.
- Starship has no asynchronous git status. In a very large repository the
  500 ms `command_timeout` cuts it off and the prompt shows no branch state.
- Finder still writes `._*` files when copying to FAT, exFAT or SMB volumes.
  `COPYFILE_DISABLE` only stops `tar`, `cp` and `rsync` from doing so. Use
  the `dotclean` alias to remove them from a volume afterwards.
- Only zsh and macOS are supported.

## License

MIT. See [LICENSE.md](LICENSE.md), which also lists the third-party code
this project builds on.
