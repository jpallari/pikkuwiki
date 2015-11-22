#!/bin/bash

__pw_links() {
    local IFS=$'\n'
    for file in $(find "$PIKKUWIKI_DIR" -name '*.txt'); do
        file=${file#$PIKKUWIKI_DIR/}
        file=${file%.txt}
        echo "$file"
    done | tr '\n' ' '
}

_pikkuwiki() {
    local cur prev cmd
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    cmd=${COMP_WORDS[1]}

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=($(compgen -W "open find resolve" -- $cur))
    elif [[ "$cmd" =~ (o|pen) || "$cmd" =~ (r|resolve) ]]; then
        COMPREPLY=($(compgen -W "$(__pw_links)" -- $cur))
    elif [[ "$cmd" =~ (f|find) ]]; then
        if [[ "$prev" =~ -(l|p|F) ]]; then
            if [ "$prev" = "-l" ]; then
                COMPREPLY=($(compgen -W "$(__pw_links)" -- $cur))
            fi
        else
            COMPREPLY=($(compgen -W "-l -p -F" -- $cur))
        fi
    fi
}

complete -F _pikkuwiki pikkuwiki
