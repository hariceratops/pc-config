#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# /proc/version is not usable for this: a container running on WSL sees the
# host's Microsoft kernel there and wrongly concludes it is WSL. wslpath and
# /mnt/c are the capabilities the Windows-side scripts actually need.
is_wsl() { command -v wslpath >/dev/null 2>&1 && [ -d /mnt/c ]; }

# ── 1. Distro packages ───────────────────────────────────────────────────────
#
# Ubuntu only, deliberately. The previous arch/ubuntu split cost 53 of this
# script's 90 lines and a three-file package layout, to serve nine entries -
# and it was silently wrong for years, because nothing running on Ubuntu can
# check that Arch really calls taskwarrior 'task'. When Arch comes back it
# arrives through nix, which has one name per package.

if ! command -v apt-get >/dev/null 2>&1; then
    echo "This bootstrap targets Ubuntu/Debian; apt-get not found." >&2
    exit 1
fi

sudo apt-get update -qq
grep -v '^\s*#' "$REPO_DIR/packages.txt" | grep -v '^\s*$' \
    | xargs sudo apt-get install -y

if [ "${GUI:-0}" = "1" ]; then
    sudo apt-get install -y rofi
fi

# ── 2. Tools that are not apt packages ───────────────────────────────────────
#
# Each of these is pinned to whatever is newest at install time, so two
# machines built a month apart do not match. That is the hole nix is meant to
# close later; until then they live here.

# neovim: apt's version is too old for this config. Lands in ~/tools because
# that is where .zshrc puts it on PATH.
NVIM_URL=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest \
    | grep '"browser_download_url"' \
    | grep 'nvim-linux-x86_64\.tar\.gz"' \
    | cut -d'"' -f4)
curl -L "$NVIM_URL" -o /tmp/nvim.tar.gz
mkdir -p "$HOME/tools"
rm -rf "$HOME/tools/nvim-linux-x86_64"
tar -xzf /tmp/nvim.tar.gz -C "$HOME/tools"
rm /tmp/nvim.tar.gz

if ! command -v rustup >/dev/null 2>&1; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y --no-modify-path
fi

# nvim-treesitter's main branch builds parsers with the CLI and needs
# 0.26.1 or later, newer than apt ships.
if [ ! -x "$HOME/.cargo/bin/tree-sitter" ]; then
    "$HOME/.cargo/bin/cargo" install tree-sitter-cli
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
        "" --unattended
fi

# ── 3. Link the dotfiles ─────────────────────────────────────────────────────
#
# Before the network-dependent extras below, and they are non-fatal, because a
# font download failing must not leave you with no dotfiles. set -e plus a chain
# of downloads previously meant any one of them aborted the whole bootstrap.

"$REPO_DIR/stow.sh"

# ── 4. Extras: nice to have, never fatal ─────────────────────────────────────

"$REPO_DIR/scripts/install_shell_tools.sh" \
    || echo "warning: shell tools failed; the prompt will fall back" >&2

"$REPO_DIR/fonts.sh" \
    || echo "warning: font install failed; prompt glyphs may render as boxes" >&2

if is_wsl; then
    "$REPO_DIR/windows-terminal.sh" || echo "warning: Windows Terminal deploy failed" >&2
    "$REPO_DIR/vscode.sh"           || echo "warning: VS Code deploy failed" >&2
fi

echo ""
echo "Done - packages installed, tools fetched, dotfiles linked."
echo "Next step:"
echo "  - chsh -s \$(which zsh)   # then log out and back in"
if is_wsl; then
    echo "  - ./vscode.sh --extensions to restore the tracked VS Code extension set"
fi
