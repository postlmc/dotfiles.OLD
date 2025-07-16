#!/bin/bash

# Prefer Docker, but if only Podman is available, alias docker to podman for compatibility
if ! command -v docker >/dev/null 2>&1 && command -v podman >/dev/null 2>&1; then
    alias docker=podman
fi

# Check for Docker or Podman (after aliasing)
command -v docker >/dev/null 2>&1 || return

# Common aliases that work with both Docker and Podman
alias dpql='docker ps -ql'
alias dpsa='docker ps -a'
alias dimgsize='docker images 2>&1 | awk '\''{sum+=$(NF-1)}END{print sum,"MB"};'\'''

alias lookl33t='docker run -t --rm --name hollywood --net none jess/hollywood; docker rm -f hollywood; clear'

## This is potentially dangerous as it deletes volumes!
alias docker-clean='docker rm $(docker ps -q -f "status=exited") 2>/dev/null \
    docker rmi $(docker images -q -f "dangling=true") 2>/dev/null \
    docker volume rm $(docker volume ls -q -f "dangling=true")  2>/dev/null'

# Docker functions
docker-flatten() {
    docker export $(docker run -d ${1} /bin/bash) | docker import – ${2}
}

## Found at: http://stackoverflow.com/questions/24481564/how-can-i-find-docker-image-with-specific-tag-in-docker-registry-in-docker-comma
docker-tags() {
    if command -v curl &>/dev/null && command -v jq &>/dev/null; then
        curl -s -S "https://registry.hub.docker.com/v2/repositories/$@/tags/" | jq '."results"[]["name"]' | sort
    else
        echo "Error: curl and jq are required for docker-tags function"
        return 1
    fi
}

## Check the balance of Docker's wonderful rate limit
docker-rl() {
    if command -v curl &>/dev/null && command -v jq &>/dev/null; then
        TOKEN=$(curl -s "https://auth.docker.io/token?service=registry.docker.io&scope=repository:ratelimitpreview/test:pull" | jq -r .token)
        curl --head -H "Authorization: Bearer $TOKEN" https://registry-1.docker.io/v2/ratelimitpreview/test/manifests/latest 2>&1 |
            grep ratelimit-
    else
        echo "Error: curl and jq are required for docker-rl function"
        return 1
    fi
}

# If Podman is available, set up the socket path
if command -v podman &>/dev/null; then
    # Check if we're on macOS and podman machine is running
    if [[ "$(uname -s)" == "Darwin"* ]]; then
        if podman machine list --format json 2>/dev/null | jq -e '.[] | select(.Running == true)' >/dev/null 2>&1; then
            export DOCKER_HOST=unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}' 2>/dev/null)
        fi
    else
        # Linux - podman socket is typically available directly
        export DOCKER_HOST=unix:///run/user/$(id -u)/podman/podman.sock
    fi
fi
