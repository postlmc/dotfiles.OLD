#!/bin/bash

command -v kubectl >/dev/null 2>&1 || return

alias k='kubectl'
alias kv='kubectl -v=6'
alias kvv='kubectl -v=9'

alias ktaints='kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints'

if command -v gum &>/dev/null; then
    kctx() {
        if [ -n "$1" ]; then
            kubectl config use-context "$1"
            return $?
        fi
        
        local current=$(kubectl config current-context 2>/dev/null)
        local contexts=($(kubectl config get-contexts -o name))
        
        if [ ${#contexts[@]} -eq 0 ]; then
            gum style --foreground 196 "No contexts available"
            return 1
        fi
        
        gum style --bold --foreground 212 "Select Kubernetes Context"
        echo
        
        local context=$(printf '%s\n' "${contexts[@]}" | \
            gum filter --placeholder="Type to filter..." \
                       --prompt="❯ " \
                       --indicator="*" \
                       --height=15)
        
        if [ -n "$context" ]; then
            gum spin --spinner dot --title "Switching context..." -- \
                kubectl config use-context "$context"
            
            if [ $? -eq 0 ]; then
                gum style --foreground 76 "Switched to context: $context"
            else
                gum style --foreground 196 "Failed to switch context"
                return 1
            fi
        else
            gum style --foreground 214 "No context selected"
            return 1
        fi
    }
elif command -v fzf &>/dev/null; then
    kctx() {
        if [ -n "$1" ]; then
            kubectl config use-context "$1"
            return $?
        fi
        
        local current=$(kubectl config current-context 2>/dev/null)
        local context=$(kubectl config get-contexts -o name | \
            fzf --height=40% --reverse --prompt="Select context: " \
                --preview="kubectl config get-contexts {}" \
                --preview-window=down:3:wrap \
                --query="$current")
        [ -n "$context" ] && kubectl config use-context "$context"
    }
else
    kctx() {
        if [ -n "$1" ]; then
            kubectl config use-context "$1"
            return $?
        fi
        
        local contexts=($(kubectl config get-contexts -o name))
        if [ ${#contexts[@]} -eq 0 ]; then
            echo "No contexts available"
            return 1
        fi
        
        echo "Available contexts:"
        PS3="Select context (number): "
        select context in "${contexts[@]}"; do
            if [ -n "$context" ]; then
                kubectl config use-context "$context"
                break
            fi
        done
    }
fi

if command -v jq &>/dev/null; then
    alias kimg="kubectl get pods --all-namespaces -o json | jq -r '.items[].spec.containers[].image' | sort | uniq -c"
else
    alias kimg="echo 'Error: jq is required for kimg alias'"
fi

alias kans='kubectl get --all-namespaces $(kubectl api-resources | awk '\''$4~/true/{printf "%s ", $1}'\'')'

ka() { kubectl "$@" --all-namespaces; }
kdr() { kubectl "$@" --dry-run=client -o yaml; }
ke() { kubectl explain "${1}" --recursive | less; }
kf() { kubectl "$@" --grace-period=0 --force; }
knh() { kubectl "$@" --no-headers; }
kns() { kubectl config set-context --current --namespace="${1}"; }

kcfg() {
    if [ -d ~/.kube ] && [ -s ~/.kube/current-context ]; then
        echo ~/.kube/current-context:$(find ~/.kube -maxdepth 1 -type f \
            \( -name '*.yml' -o -name '*.yaml' \) ! -name '.*' ! -name '_*' | tr '\n' ':')
    fi
}
export KUBECONFIG=$(kcfg)

# whence -w minikube >/dev/null 2>&1 &&
#     # minikube config set vm-driver hyperkit && \
#     alias mk='KUBECONFIG=${HOME}/.kube/minikube.yml minikube' &&
#     export MINIKUBE_IN_STYLE=false

# Shell completion setup
if command -v kubelogin >/dev/null 2>&1; then
    if [[ -n "$ZSH_VERSION" ]]; then
        source <(kubelogin completion zsh 2>/dev/null) 2>/dev/null || true
    elif [[ -n "$BASH_VERSION" ]]; then
        source <(kubelogin completion bash 2>/dev/null) 2>/dev/null || true
    fi
fi

# Kubectl completion
if [[ -n "$ZSH_VERSION" ]]; then
    source <(kubectl completion zsh 2>/dev/null) 2>/dev/null || true
elif [[ -n "$BASH_VERSION" ]]; then
    source <(kubectl completion bash 2>/dev/null) 2>/dev/null || true
fi
