#!/bin/sh

# Read env variables
[ -z "$PIKKUWIKI_DIR" ] && PIKKUWIKI_DIR="$HOME/pikkuwiki"
[ -z "$EDITOR" ] && EDITOR=vi
[ -z "$PW_DEFAULT_PAGE" ] && PW_DEFAULT_PAGE="index"

# Enable "strict" mode
set -eu

# Pattern for recognizing links to other files
LINK_PATTERN='~[_/[:alnum:]]\+'

NEWL='
'

grep_links() {
    grep -ow "$LINK_PATTERN"
}

filename_to_link() {
    local link
    link=${1#$PIKKUWIKI_DIR}
    link=${link#/}
    link=${link%.txt}
    echo "$link"
}

starts_with() {
    local str="$1"
    local prefix="$2"
    local prefix_len=${#prefix}
    [ "$(echo "$str" | cut -c"$prefix_len")" = "$prefix" ]
}

resolve_link() {
    local context=${1#$PIKKUWIKI_DIR}
    context="/${context#/}"
    context=${context%/*}
    local link=${2#\~}
    link=${link%.*}
    link=${link:-$PW_DEFAULT_PAGE}

    if $(starts_with "$link" "/") || [ "$context" = "/" ]; then
        context="$PIKKUWIKI_DIR"
    else
        context="$PIKKUWIKI_DIR$context"
    fi

    link=${link#/}

    echo "$context/$link.txt"
}

resolve_links() {
    while read line; do
        resolve_link "$1" "$line"
    done
}

find_links_from_file() {
    grep_links < "$1" | grep "$2" | resolve_links "$filename"
}

find_links_from_directory() {
    local IFS="$NEWL"
    local dir="$1"
    local pattern="$2"
    for filename in $(text_files "$dir"); do
        find_links_from_file "$filename" "$pattern"
    done
}

text_files() {
    find "$1" -name '*.txt'
}

find_links() {
    local filename="${1:-}"
    local pattern=${2:-}

    if [ ! "$filename" ]; then
        filename="$PIKKUWIKI_DIR"
    elif [ ! -f "$filename" ]; then
        filename=$(resolve_link "" "$filename")
    fi

    if [ -f "$filename" ]; then
        find_links_from_file "$filename" "$pattern"
    elif [ -d "${filename%.txt}" ]; then
        find_links_from_directory "${filename%.txt}" "$pattern"
    fi | sort -u
}

formatter_pretty() {
    local filename=${1:-}
    local heading="[No file]"
    [ -f "$filename" ] && heading=$(head -n1 "$filename")
    local link=$(filename_to_link "$filename")

    printf "%s:	%s\n" "$link" "$heading"
}

after_formatter_pretty() {
    column -t -s"	"
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
    local link=""
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
    $EDITOR "$(resolve_link "" "$link")"
}

# Main program
run_pikkuwiki() {
    case ${1:-} in
        o|open)
            open_link "${2:-}" ;;
        f|find)
            shift
            find_and_format_links "$@" ;;
        r|resolve)
            resolve_link "${2:-}" "${3:-}" ;;
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
              PW_DEFAULT_PAGE or "index" is opened instead.

  f, find     find links from a given link, file, or directory
              using given pattern. Outputs the filenames of found
              links unless alternatiove formatting is provided.

  r, resolve  resolve filename for given filename and link combination

Find arguments:
  -l          link, file, or directory to search links from.
              Directories are scanned recursively for .txt files.

  -p          RegEx pattern to use for filtering links.
              By default, no filtering is done.

  -F          Use alternative formatting from PW_PRETTY_FORMAT.

Environment variables:
  PIKKUWIKI_DIR           The directory where pages are located.
                        Default: $HOME/pikkuwiki

  EDITOR                The editor that the open command launches
                        Default: vi

  PW_DEFAULT_PAGE       The default page that is opened if no link
                        is provided for open command.
                        Default: index

Link format:
  All links to other pages start with tilde (~).
  All pages point to a .txt file.
  The page which the link refers to depends on where the page that is linking.

  Absolute links:
    ~/Europe            => $PIKKUWIKI_DIR/Europe.txt
    ~/Europe/Germany    => $PIKKUWIKI_DIR/Europe/Germany.txt

  Relative links in '~/Europe' page:
    ~America            => $PIKKUWIKI_DIR/America.txt
    ~America/Canada     => $PIKKUWIKI_DIR/America/Canada.txt

  Relative links in '~/Europe/Germany' page:
    ~Berlin             => $PIKKUWIKI_DIR/Europe/Germany/Berlin.txt
    ~Munich             => $PIKKUWIKI_DIR/Europe/Germany/Munich.txt

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

  Resolve link:
    pikkuwiki resolve Europe Germany
    pikkuwiki r $PIKKUWIKI_DIR/Europe/Germany.txt Berlin
EOF
}

