#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
DOTFILES_DIR="$REPO_DIR/dotfiles"

CLI_PACKAGES="bash git zsh nvim vim tmux taskwarrior ranger"
GUI_PACKAGES="rofi"

STOW_PACKAGES="$CLI_PACKAGES"
[ "${GUI:-0}" = "1" ] && STOW_PACKAGES="$STOW_PACKAGES $GUI_PACKAGES"

for pkg in $STOW_PACKAGES; do
    pkg_dir="$DOTFILES_DIR/$pkg"
    [ -d "$pkg_dir" ] || continue

    # Back up any real files that would conflict with stow targets.
    # Compare resolved paths rather than testing "-L $target": when a parent
    # dir got tree-folded into a single symlink by a prior stow run, $target
    # is already the repo file (reached through that symlink) even though
    # its own path isn't a symlink - treating it as a conflict would mv the
    # tracked repo file itself into a .bak.
    while IFS= read -r -d '' src; do
        rel="${src#$pkg_dir/}"
        target="$HOME/$rel"
        if [ -e "$target" ] && [ "$(readlink -f -- "$target")" != "$(readlink -f -- "$src")" ]; then
            echo "Backing up $target -> $target.bak"
            mv "$target" "$target.bak"
        fi
    done < <(find "$pkg_dir" -type f -print0)

    # --restow, not plain stow: stow never removes a link whose target has
    # gone, so deleting a tracked file leaves a dangling symlink in $HOME that
    # nothing complains about. That is exactly how ~/.config/nvim ended up
    # pointing at an init_bkp.lua and a plugin/ that no longer exist.
    stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$pkg"
done

echo "Done."
