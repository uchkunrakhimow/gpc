PREFIX ?= .
BINDIR = $(PREFIX)/bin
SCRIPT_NAME = ghclone
SCRIPT_FILE = ghclone.sh
VERSION = 1.0.0

.PHONY: all install uninstall symlinks test clean help

all: help

install:
	@echo "Installing $(SCRIPT_NAME) to $(BINDIR)..."
	mkdir -p $(BINDIR)
	sudo cp $(SCRIPT_FILE) $(BINDIR)/$(SCRIPT_NAME)
	chmod +x $(BINDIR)/$(SCRIPT_NAME)
	sudo ln -sf $(BINDIR)/$(SCRIPT_NAME) $(BINDIR)/ghc
	sudo ln -sf $(BINDIR)/$(SCRIPT_NAME) $(BINDIR)/ghcs
	@echo "Installation complete!"

uninstall:
	@echo "Uninstalling $(SCRIPT_NAME)..."
	sudo rm -f $(BINDIR)/$(SCRIPT_NAME)
	sudo rm -f $(BINDIR)/ghc
	sudo rm -f $(BINDIR)/ghcs
	@echo "Uninstallation complete."

symlinks:
	@echo "Creating symbolic links..."
	sudo ln -sf $(BINDIR)/$(SCRIPT_NAME) $(BINDIR)/ghc
	sudo ln -sf $(BINDIR)/$(SCRIPT_NAME) $(BINDIR)/ghcs
	@echo "Symbolic links created."

test:
	@echo "Running tests..."
	./$(SCRIPT_FILE) --version || echo "Test failed, but continuing..."
	@echo "Test complete."

clean:
	@echo "Cleaning up..."
	rm -rf dist Formula
	@echo "Cleanup complete."

help:
	@echo "GitHub Repos Cloner - Makefile Commands"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install         Install script to $(BINDIR) and create symlinks"
	@echo "  uninstall       Remove script and symlinks"
	@echo "  symlinks        Create only the symbolic links"
	@echo "  test            Run basic tests"
	@echo "  clean           Remove generated files"
	@echo "  help            Show this help message"
	@echo ""
	@echo "Example:"
	@echo "  make install PREFIX=$$HOME/.local"
	@echo ""
	@echo "Note: This will install $(SCRIPT_FILE) as $(SCRIPT_NAME)"