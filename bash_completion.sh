#!/bin/bash

__pw_links() {
    pikkuwiki find -F | cut -d: -f1 | tr '\n' ' '
}

_pikkuwiki() {
    local cur prev cmd
    local commands="open find show resolve view"
    local flags="-l -p -F"
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    cmd=${COMP_WORDS[1]}

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=($(compgen -W "$commands" -- $cur))
    elif [[ "$cmd" =~ (o|pen) || "$cmd" =~ (r|resolve) || "$cmd" =~ (v|view) ]]; then
        COMPREPLY=($(compgen -W "$(__pw_links)" -- $cur))
    elif [[ "$cmd" =~ (f|find) ]]; then
        if [[ "$prev" =~ -(p|F) ]]; then
            if [ "$prev" = "-F" ]; then
                COMPREPLY=($(compgen -W "$flags" -- $cur))
            fi
        else
            COMPREPLY=($(compgen -W "$flags" -- $cur))
        fi
    elif [[ "$cmd" =~ (s|show) ]]; then
        if [[ "$prev" =~ -(l|p|F) ]]; then
            if [ "$prev" = "-l" ]; then
                COMPREPLY=($(compgen -W "$(__pw_links)" -- $cur))
            elif [ "$prev" = "-F" ]; then
                COMPREPLY=($(compgen -W "$flags" -- $cur))
            fi
        else
            COMPREPLY=($(compgen -W "$flags" -- $cur))
        fi
    fi
}

complete -F _pikkuwiki pikkuwiki
