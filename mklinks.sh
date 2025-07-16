#!/usr/bin/env bash

# Links files in this directory to the current users home directory. If the link
# already exists the file will be skipped unless the -f flag is given. The -p
# flag can be used to link in an alternate location (default is ${HOME}).
#
# Original shamelessly lifted from https://gist.github.com/975295

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd -P)"
NO_LINK="${SCRIPT_DIR}/nolink"
PREFIX="${HOME}"
FORCE=0

while getopts "fp:" flag; do
    case "${flag}" in
    f)
        FORCE=1
        echo "Forcibly linking as needed"
        ;;
    p) PREFIX="${OPTARG}" ;;
    esac
done

for TARGET_FILE in "${SCRIPT_DIR}"/*; do
    DOT_FILE=$(basename "${TARGET_FILE}")
    # Skip the script itself and directories
    if [[ "${DOT_FILE}" == "$(basename "$0")" ]] || [[ -d "${TARGET_FILE}" ]]; then
        continue
    fi
    # Skip if in NO_LINK
    if [[ -f "${NO_LINK}" ]] && grep -E -q "^${DOT_FILE}$" "${NO_LINK}"; then
        continue
    fi
    LINK="${PREFIX}/.${DOT_FILE}"
    if [ -e "${LINK}" ]; then
        if [ -L "${LINK}" ] && [ "$(readlink -f "${LINK}" 2>/dev/null || readlink "${LINK}")" = "${TARGET_FILE}" ]; then
            echo "${LINK} already correctly linked, skipping"
            continue
        fi
        if [[ ${FORCE} -eq 1 ]]; then
            echo "Forcibly linking ${LINK} to ${TARGET_FILE}"
            rm -f "${LINK}"
        else
            echo "${LINK} already exists, use -f to force overwrite"
            continue
        fi
    fi
    echo "Linking ${LINK} to ${TARGET_FILE}"
    if ! ln -s "${TARGET_FILE}" "${LINK}"; then
        echo "Error: Failed to create symlink ${LINK}" >&2
        continue
    fi
done
