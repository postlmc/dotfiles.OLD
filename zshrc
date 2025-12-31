#!/bin/zsh

# Load a host-specific config (if any) to establish locations of key binaries
HOST=$(hostname -s | sed 's/-.gbe$//g' | tr "[:upper:]" "[:lower:]")
[[ -r ${HOME}/.dotfiles.local/${HOST}-bootstrap ]] &&
    . ${HOME}/.dotfiles.local/${HOST}-bootstrap

# First, set up all completion paths (fpath and FPATH)
# Then, configure completion styles (zstyle)
# Finally, initialize the completion system (compinit) once

# Set up completion paths
fpath=(
    ~/.zsh/completion
    $fpath
)

# Cache completions
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# Completion system setup
# Only run compinit once; -C skips security checks (faster, but only if you trust your completions)
autoload -U +X compinit && compinit -C
autoload -U +X bashcompinit && bashcompinit # Needed for bash-style 'complete' below

[[ -f ${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source ${HOME}/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
[[ -f ${HOME}/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source ${HOME}/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[[ -f ${HOME}/.zsh/zsh-hist/zsh-hist.plugin.zsh ]] && source ${HOME}/.zsh/zsh-hist/zsh-hist.plugin.zsh
[[ -f ${HOME}/.fzf.zsh ]] && source ${HOME}/.fzf.zsh

# Symlink additional configs in .dotfiles/enabled to have them sourced, numbering for order
# (these may have additional completions)
for CFG in ${HOME}/.dotfiles/enabled/??-*; do
    . ${CFG}
done

# Ref: https://zsh.sourceforge.io/Doc/Release/User-Contributions.html#Accessing-On_002dLine-Help
unalias run-help
autoload run-help

# Helps with uv default python installed with: `uv python install 3.12 --default --preview`
[[ -d "${HOME}/.local/bin" ]] && prepend_path PATH ${HOME}/.local/bin
[[ -d "${HOME}/bin" ]] && prepend_path PATH ${HOME}/bin

# History configuration (works on both macOS and Linux)
export HISTFILE=~/.zsh_history
export HISTSIZE=1200000
export SAVEHIST=1000000

# Timestamps: zsh stores timestamps if EXTENDED_HISTORY is set (see below).
# To view timestamps, use: history -i

# Ref: https://zsh.sourceforge.io/Doc/Release/Options.html#Options
# History sharing: unsetopt SHARE_HISTORY means each session keeps its own history until exit.
unsetopt SHARE_HISTORY
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_REDUCE_BLANKS
unsetopt INC_APPEND_HISTORY
setopt INC_APPEND_HISTORY_TIME
setopt EXTENDED_HISTORY

(( $+commands[fzf] )) && eval "$(fzf --zsh)"
