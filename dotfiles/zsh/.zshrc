# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
export PATH="$HOME/tools/zig:$HOME/tools/nvim-linux-x86_64/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME="agnoster"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(
#     git
#     taskwarrior
#     zsh-autosuggestions
#     zsh-syntax-highlighting
#   )

# Installed by scripts/install_shell_tools.sh, not by a package manager.
# Guarded so a machine that has not run it yet still gets a usable shell
# instead of an error on every prompt.
#
# Must precede oh-my-zsh: autocomplete adds its Completions/ to fpath at source
# time, then reuses whatever dump oh-my-zsh's compinit wrote. If oh-my-zsh runs
# first, that dump lacks _autocomplete__unambiguous and friends, and every Tab
# fails with "command not found".
[ -f ~/tools/zsh-autocomplete/zsh-autocomplete.plugin.zsh ] \
    && source ~/tools/zsh-autocomplete/zsh-autocomplete.plugin.zsh

[ -f "$ZSH/oh-my-zsh.sh" ] && source "$ZSH/oh-my-zsh.sh"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[ -f ~/tools/powerlevel10k/powerlevel10k.zsh-theme ] \
    && source ~/tools/powerlevel10k/powerlevel10k.zsh-theme

# zsh-autocomplete binds menu-search and recent-paths before it creates them,
# and zsh-syntax-highlighting warns about every bound-but-undefined widget it
# meets while wrapping. Stub those so the wrap is clean and complete;
# autocomplete's own zle -N / zle -C overwrite the stubs unconditionally during
# its deferred init, so this only fills the gap between the two.
#
# Ordering highlighting before autocomplete also silences the warning, but it
# then never wraps autocomplete's history widgets, and the recalled line is
# left unhighlighted on every arrow-key press.
_pc_stub_widget() { }
() {
    local w
    for w in ${(u)${(f)"$(bindkey)"}##* }; do
        (( $+widgets[$w] )) || zle -N "$w" _pc_stub_widget
    done
}

# Distro package, but the two distros disagree on where it lands.
for _zsh_hl in \
    /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
    /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
    [ -f "$_zsh_hl" ] && source "$_zsh_hl" && break
done
unset _zsh_hl

# uv, installed by scripts/install_shell_tools.sh
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# tmux workspace templates - `ws agent ~/code/foo`, or prefix + N inside tmux
ws() { ~/.config/tmux/scripts/tmux-workspace.sh "$@"; }
