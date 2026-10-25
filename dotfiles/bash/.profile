export EDITOR=nvim
export QT_QPA_PLATFORMTHEME="qt5ct"
export QT_AUTO_SCREEN_SCALE_FACTOR=0
export GTK2_RC_FILES="$HOME/.gtkrc-2.0"
export LS_COLORS="di=1;33"
# Guarded: rustup is installed by install.sh, but a machine that has not run it
# yet should still get a working login shell rather than an error.
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
