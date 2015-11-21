#!/bin/sh

# Read env variables
[ -z "$PW_WIKI_DIR" ] && PW_WIKI_DIR="$HOME/pikkuwiki"
[ -z "$EDITOR" ] && EDITOR=vi
[ -z "$PW_DEFAULT_PAGE" ] && PW_DEFAULT_PAGE="Index"

# Enable "strict" mode
set -euo pipefail

# Pattern for recognizing links to other files
LINK_PATTERN='~[_/[:alnum:]]\+'

grep_links() {
    grep -o "$LINK_PATTERN"
}

filename_to_link() {
    local link
    link=${1#$PW_WIKI_DIR}
    link=${link#/}
    link=${link%.txt}
    echo "$link"
}

expand_link() {
    local context=${1%/}
    local link=${2#\~}
    if [ ! "$(echo "$link" | cut -c1)" = "/" ]; then
        link="$context/$link"
    fi
    echo "$PW_WIKI_DIR/${link#/}.txt"
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

find_links() {
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

format_pretty() {
    local filename=${1:-}
    local heading="[No file]"
    [ -f "$filename" ] && heading=$(head -n1 "$filename")
    local link=$(filename_to_link "$filename")
    echo "$link:	$heading"
}

format_links() {
    local format=${1:-}
    local formatter="echo"
    local after_formatter="cat"

    if [ "$format" = "pretty" ]; then
        formatter="format_pretty"
        after_formatter="column -t -s\"$(printf \t)\""
    fi

    while read line; do
        $formatter "$line"
    done | $after_formatter
}

find_and_format_links() {
    local link
    local pattern=""
    local format=""
    while getopts "l:p:F:" flag; do
        case "$flag" in
            l) link=$OPTARG ;;
            p) pattern=$OPTARG ;;
            F) format=$OPTARG ;;
        esac
    done
    find_links "$link" "$pattern" | format_links "$format"
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
        find_and_format_links "$@" ;;
    *)
        echo "TODO: help"
        ;;
esac
