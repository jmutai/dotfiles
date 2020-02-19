#!/bin/bash
output=""

pass_result=$(cd ~/.password-store && git status | grep 'working tree clean')
if [ -z "$pass_result" ]; then
    if [[ "$output" ]]; then
        output="${output}, "
    fi
    output="${output}pass"
fi

note_result=$(cd ~/note && git status | grep 'working tree clean')
if [ -z "$note_result" ]; then
    if [[ "$output" ]]; then
        output="${output}, "
    fi
    output="${output}note"
fi

doc_result=$(cd ~/doc && git status | grep 'working tree clean')
if [ -z "$doc_result" ]; then
    if [[ "$output" ]]; then
        output="${output}, "
    fi
    output="${output}doc"
fi

sync_result=$(cd ~/sync && git status | grep 'working tree clean')
if [ -z "$sync_result" ]; then
    if [[ "$output" ]]; then
        output="${output}, "
    fi
    output="${output}sync"
fi

if [[ $output ]];then
    echo "{\"text\":\"$output\"}"
fi
