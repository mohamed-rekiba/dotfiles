.DEFAULT_GOAL := help

BATS ?= bats
SHELL := /bin/bash

.PHONY: help install brew macos test lint

help: ## Show this help
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F ':.*## ' '{ printf "  %-10s %s\n", $$1, $$2 }'

install: ## Symlink the dotfiles into $$HOME and ~/.config
	./install.sh

# Homebrew leaves share/ group-writable, which makes zsh's compinit refuse the
# completions installed there. The chmod is Homebrew's documented fix.
brew: ## Install packages from the Brewfile
	brew bundle --file=Brewfile
	chmod go-w "$$(brew --prefix)/share"

macos: ## Apply the macOS defaults
	./macos.sh

lint: ## Shellcheck the scripts and syntax-check the zsh files
	$(BATS) tests/lint.bats

test: ## Run the whole test suite
	$(BATS) tests/
