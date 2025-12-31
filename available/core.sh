#!/bin/bash

# Essential shell behavior for consistent history and command editing
set -o vi

# Ensure consistent character encoding across all tools
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Enable color output for better visual parsing of command output
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Prevent accidental file operations
alias rm='rm -I --preserve-root'
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# Common ls variations for different detail levels
alias ll='ls -l'
alias la='ls -la'
alias l='ls -CF'

# [Way too] Common typos
alias ls-la='ls -la'
alias ls-l='ls -l'
alias ln-s='ln -s'
alias cd..='cd ..'
alias rm-f='rm -f'
alias rm-rf='rm -rf'

# Navigation shortcuts for faster directory traversal
alias ..='cd ..'
alias ...='cd ../..'
alias ..3='cd ../../..'
alias ..4='cd ../../../..'
alias ..5='cd ../../../../..'

# Show octal permissions for easier chmod reference
alias lso="ls -alG | \
    awk '{k=0;for(i=0;i<=8;i++)k+=((substr(\$1,i+2,1)~/[rwx]/)*2^(8-i));if(k)printf(\" %0o \",k);print}'"

# ISO 8601 is your friend

# Local (server) time
alias now="date '+%Y-%m-%dT%H:%M:%S%z'"
alias nowc="date '+%Y%m%dT%H%M%S%Z'"

# UTC (zulu) time
alias zulu="date -u '+%Y-%m-%dT%H:%M:%S%z'"
alias zuluc="date -u '+%Y%m%dT%H%M%SZ'"

if command -v curl &>/dev/null; then
    # curl-trace from https://github.com/wickett/dotfiles/blob/master/.curl-format
    alias curl-trace='curl -so /dev/null -w "@${HOME}/.dotfiles/curl-format"'
    alias curl-status='curl -skw "%{http_code}" -o /dev/null'
    alias myip='curl -s http://ifconfig.me/ip'
fi

# Network utilities - check for availability
if command -v dig &>/dev/null; then
    alias digs='dig +short'
fi

alias sortip='sort -t . -k 1,1n -k 2,2n -k 3,3n -k 4,4n'

# WHOIS utilities - check for availability
if command -v whois &>/dev/null; then
    alias apnic='whois -h whois.apnic.net'
    alias ripe='whois -h whois.ripe.net'
    alias arin='whois -h whois.arin.net'
    alias afrinic='whois -h whois.afrinic.net'
    alias lacnic='whois -h whois.lacnic.net'
    alias org='whois -h whois.pir.org'
    alias edu='whois -h whois.educause.edu'
    alias cctld='whois -h whois.iana.org'
    alias bgp='whois -h riswhois.ripe.net'
fi

# Handy backup functions for moving things around
if command -v nc &>/dev/null; then
    send() {
        HOST=$1
        shift
        echo "Sending to $HOST:10301..."
        if command -v pv >/dev/null 2>&1; then
            tar czf - $@ | pv | nc -Nv $HOST 10301
        else
            echo 1>&2 "pv not found, so no stats for you!"
            tar cvzf - $@ | nc -Nv $HOST 10301
        fi
        echo "Done"
    }

    recv() {
        echo "$(hostname -f): Listening on port 10301..."
        nc -nlv 10301 | tar xvzp 2>/dev/null
        echo "Done"
    }
fi

# Function wrappers for common commands
ls-() {
    ls -$@
}

rm-() {
    rm -$@
}

# Random string generation functions
randh() {
    LC_ALL=C tr -dc 'a-f0-9' </dev/urandom | head -c${1:-16}
}

randa() {
    LC_ALL=C tr -dc '[:alnum:]' </dev/urandom | head -c${1:-16}
}

randg() {
    LC_ALL=C tr -dc '[:graph:]' </dev/urandom | head -c${1:-16}
}

# Useful way to strip HTML down to ASCII
if command -v lynx &>/dev/null; then
    alias html2ascii='lynx -force_html -stdin -dump -nolist'
fi

if command -v tmux &>/dev/null; then
    alias tmux='tmux -2'
    alias tmuxa='tmux -2 attach -t'
fi

# Set EDITOR with fallback
if [ -n "$HOMEBREW_PREFIX" ] && [ -x "${HOMEBREW_PREFIX}/bin/vim" ]; then
    export EDITOR="${HOMEBREW_PREFIX}/bin/vim"
elif command -v vim &>/dev/null; then
    export EDITOR="vim"
elif command -v vi &>/dev/null; then
    export EDITOR="vi"
else
    export EDITOR="nano"
fi

# Common environment variables
export GZIP=-9
export CASE_SENSITIVE="true"
export QUOTING_STYLE=literal
