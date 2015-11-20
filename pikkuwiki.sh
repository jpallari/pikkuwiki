#!/bin/sh

# Read env variables
if [ -z "$PW_WIKI_DIR" ]; then
    PW_WIKI_DIR="$HOME/pikkuwiki"
fi

if [ -z "$EDITOR" ]; then
    EDITOR=vi
fi

if [ -z "$PW_DEFAULT_PAGE" ]; then
    PW_DEFAULT_PAGE="Index"
fi


# Enable "strict" mode
set -euo pipefail

# Pattern for recognizing links to other files
LINK_PATTERN='~[_/[:alnum:]]\+'

grep_links() {
    grep -o "$LINK_PATTERN"
}

heading() {
    head -n1
}

expand_link() {
    local context=${1%/}
    local link=${2#\~}
    if [ ! "$(echo "$link" | cut -c1)" = "/" ]; then
        link="$context/$link"
    fi
    echo "$PW_WIKI_DIR/${link#/}.txt"
}

make_link() {
    local link
    link=${1#$PW_WIKI_DIR}
    link=${link#/}
    link=${link%.txt}
    echo "~$link"
}

make_links() {
    while read line; do
        make_link "$line"
    done
}

expand_links() {
    while read line; do
        expand_link "$1" "$line"
    done
}

find_links_from_file() {
    grep_links < "$1" | grep "$2"
}

find_links_from_directory() {
    local IFS=$(printf '\n')
    for filename in $(text_files "$1"); do
        find_links_from_file "$filename" "$2"
    done
}

text_files() {
    find "$1" -iname '*.txt'
}

find_files() {
    local link=${1:-}
    local filename="$link"
    local pattern=${2:-}

    if [ ! -f "$filename" ]; then
        filename=$(expand_link "" "$link")
    fi

    if [ -f "$filename" ]; then
        find_links_from_file "$filename" "$pattern"
    elif [ -d "${filename%.txt}" ]; then
        find_links_from_directory "${filename%.txt}" "$pattern"
    fi | expand_links "" | sort -u
}

open_link() {
    local link=${1:-$PW_DEFAULT_PAGE}
    $EDITOR "$(expand_link "" "$link")"
}


# Main program
case ${1:-} in
    o|open)
        open_link "${2:-}" ;;
    f|find)
        shift
        find_files "$@" ;;
    *)
        echo "TODO: help"
        ;;
esac
