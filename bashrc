#!/bin/bash

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Load a host-specific config (if any) to establish locations of key binaries
HOST=$(hostname -s | sed 's/-.gbe$//g' | tr "[:upper:]" "[:lower:]")
[[ -r ${HOME}/.dotfiles.local/${HOST}-bootstrap ]] &&
    . ${HOME}/.dotfiles.local/${HOST}-bootstrap

# History configuration
export HISTFILE=~/.bash_history
export HISTSIZE=1000000
export HISTFILESIZE=1000000
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="&:ls:[bf]g:exit"

# Essential shell behavior for consistent history and command editing
shopt -s histappend
shopt -s checkwinsize

# Function to manage shell options
shopt-alias() {
    for OPT in $(shopt | awk '{print $1}'); do
        # Don't stomp on any existing stuff
        if ! command -v $OPT >/dev/null 2>&1 && ! alias $OPT 2>/dev/null && ! declare -f $OPT; then
            alias $OPT="if shopt -q $OPT; then shopt -u $OPT && echo \"$OPT off\"; \
                else shopt -s $OPT && echo \"$OPT on\"; fi"
        fi
    done
}
shopt-alias

# Source additional configs in .dotfiles/enabled, numbering for order
for CFG in ${HOME}/.dotfiles/enabled/??-*; do
    [[ -r "${CFG}" ]] && . "${CFG}"
done

# Helps with uv default python installed with: `uv python install 3.12 --default --preview`
[[ -d "${HOME}/.local/bin" ]] && prepend_path PATH ${HOME}/.local/bin
[[ -d "${HOME}/bin" ]] && prepend_path PATH ${HOME}/bin

[[ -f /usr/local/etc/bash_completion ]] &&
    . /usr/local/etc/bash_completion

if command -v kubectl &>/dev/null 2>&1; then
    source <(kubectl completion bash)
fi
if command -v kubelogin &>/dev/null 2>&1; then
    source <(kubelogin completion bash)
fi

command -v fzf >/dev/null 2>&1 && eval "$(fzf --bash)"
