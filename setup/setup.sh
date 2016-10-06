#!/usr/bin/env bash
set -eu

# use ask function
# http://djm.me/ask
ask () {
    while true; do
        if [ "${2:-} = "Y" ]; then
            prompt="Y/n"
            default=Y
        elif [ "${2:-}" = "N" ]; then
            prompt="y/N"
            default=N
        else
            prompt="y/n"
            default=
        fi

        # Ask the question
        read -p "$1 [$prompt] " REPLY

        # default?
        if [ -z "$REPLY" ]; then
            REPLY=$default
        fi

        # Check if the reply is valid
        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
}

# check if current dir name is setup
dir=$(basename `pwd`)
if [  $dir != "setup" ];then
    echo " Run script inside setup directory. Aborting!!"
    exit 1
fi

# Install dependencies
