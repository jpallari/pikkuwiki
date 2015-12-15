#!/bin/bash

_pikkuwiki() {
    local cur prev cmd
    local commands="open find show resolve view"
    local formatters="header link file pretty space"
    local show_flags="-l -p -F"
    local find_flags="-p -F"
    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}
    cmd=${COMP_WORDS[1]}

    if [ $COMP_CWORD -eq 1 ]; then
        COMPREPLY=($(compgen -W "$commands" -- $cur))
    elif [[ "$cmd" =~ ^(o|pen)$ || "$cmd" =~ ^(r|resolve)$ || "$cmd" =~ ^(v|view)$ ]]; then
        COMPREPLY=($(compgen -W "$(pikkuwiki find -F space)" -- $cur))
    elif [[ "$cmd" =~ ^(f|find)$ ]]; then
        if [[ "$prev" =~ ^-(p|F)$ ]]; then
            if [ "$prev" = "-F" ]; then
                COMPREPLY=($(compgen -W "$formatters" -- $cur))
            fi
        else
            COMPREPLY=($(compgen -W "$find_flags" -- $cur))
        fi
    elif [[ "$cmd" =~ ^(s|show)$ ]]; then
        if [[ "$prev" =~ ^-(l|p|F)$ ]]; then
            if [ "$prev" = "-l" ]; then
                COMPREPLY=($(compgen -W "$(pikkuwiki find -F space)" -- $cur))
            elif [ "$prev" = "-F" ]; then
                COMPREPLY=($(compgen -W "$formatters" -- $cur))
            fi
        else
            COMPREPLY=($(compgen -W "$show_flags" -- $cur))
        fi
    fi
}

complete -F _pikkuwiki pikkuwiki
