#!/bin/sh

# Read env variables
[ -z "$PW_WIKI_DIR" ] && PW_WIKI_DIR="$HOME/pikkuwiki"
[ -z "$EDITOR" ] && EDITOR=vi
[ -z "$PW_DEFAULT_PAGE" ] && PW_DEFAULT_PAGE="Index"
[ -z "$PW_PRETTY_FORMAT" ] && PW_PRETTY_FORMAT="%l:	%h"

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

sed_escape() {
    echo "$1" | sed -e 's/[\/&]/\\&/g'
}

formatter_pretty() {
    local filename=${1:-}
    local heading="[No file]"
    [ -f "$filename" ] && heading=$(head -n1 "$filename")
    local link=$(filename_to_link "$filename")

    filename=$(sed_escape "$filename")
    heading=$(sed_escape "$heading")
    link=$(sed_escape "$link")

    local result=$(echo "$PW_PRETTY_FORMAT" | sed \
        -e "s/%l/$link/g" \
        -e "s/%h/$heading/g" \
        -e "s/%f/$filename/g")
    printf "$result\n"
}

after_formatter_pretty() {
    column -t -s"$(printf '\t')"
}

format_links() {
    local format=${1:-}
    local formatter="echo"
    local after_formatter="cat"

    if "$format"; then
        formatter="formatter_pretty"
        after_formatter="after_formatter_pretty"
    fi

    while read line; do
        $formatter "$line"
    done | $after_formatter
}

find_and_format_links() {
    local link
    local pattern=""
    local format=false
    while getopts "l:p:F" flag; do
        case "$flag" in
            l) link=$OPTARG ;;
            p) pattern=$OPTARG ;;
            F) format=true ;;
        esac
    done
    find_links "$link" "$pattern" | format_links "$format"
}

open_link() {
    local link=${1:-$PW_DEFAULT_PAGE}
    $EDITOR "$(expand_link "" "$link")"
}

# Main program
run_pikkuwiki() {
    case ${1:-} in
        o|open)
            open_link "${2:-}" ;;
        f|find)
            shift
            find_and_format_links "$@" ;;
        *)
            print_help
            ;;
    esac
}

print_help() {
    cat <<'EOF'
pikkuwiki - Minimal personal wiki tools

usage: pikkuwiki <command> [arguments]

Commands:
  o, open     open a given link using EDITOR. If link is empty,
              PW_DEFAULT_PAGE or "Index" is opened instead.

  f, find     find links from a given link, file, or directory
              using given pattern. Outputs the filenames of found
              links unless alternatiove formatting is provided.

Find arguments:
  -l          link, file, or directory to search links from.
              Directories are scanned recursively for .txt files.

  -p          RegEx pattern to use for filtering links.
              By default, no filtering is done.

  -F          Use alternative formatting from PW_PRETTY_FORMAT.

Environment variables:
  PW_WIKI_DIR           The directory where pages are located.
                        Default: $HOME/pikkuwiki

  EDITOR                The editor that the open command launches
                        Default: vi

  PW_DEFAULT_PAGE       The default page that is opened if no link
                        is provided for open command.
                        Default: Index

  PW_PRETTY_FORMAT      The format to use in alternative formatting.
                        Default: "%l:\t%h"

Link format:
  All links to other pages start with tilde (~).
  All pages point to a .txt file.
  The page which the link refers to depends on where the page that is linking.

  Absolute links:
    ~/Europe            => $PW_WIKI_DIR/Europe.txt
    ~/Europe/Germany    => $PW_WIKI_DIR/Europe/Germany.txt

  Relative links in '~/Europe' page:
    ~America            => $PW_WIKI_DIR/America.txt
    ~America/Canada     => $PW_WIKI_DIR/America/Canada.txt

  Relative links in '~/Europe/Germany' page:
    ~Berlin             => $PW_WIKI_DIR/Europe/Germany/Berlin.txt
    ~Munich             => $PW_WIKI_DIR/Europe/Germany/Munich.txt

Alternative formatter:
  Alternative formatter has three templates which will be formatted

  %l        The absolute link to the page
  %h        The heading (first line) of the page.
  %f        The filename of the page.

Examples:
  Open a page in editor:
    pikkuwiki open '~America/Canada'
    pikkuwiki o Europe/Germany

  Find all links in a page or directory and print out as filenames:
    pikkuwiki find -l Europe/Germany
    pikkuwiki f -l Europe

  Find matching links:
    pikkuwiki f -l Europe/Germany -p 'Ber'
EOF
}

