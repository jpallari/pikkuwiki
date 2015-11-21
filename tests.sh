#!/bin/bash

# Load source code
source pikkuwiki.sh

# Allow errors to collect test results
set +e

# Change this mid script to control indentation on test messages
ASSERT_INDENT=2

print_indent() {
    printf "%${ASSERT_INDENT}s"
}

# Assertion based on last commands result code
assert() {
    local result="${2:-$?}"
    print_indent
    if [ "$result" = 0 ]; then
        echo -e "\e[1;32mSuccess:\e[0m $1"
    else
        echo -e "\e[0;31mFailure:\e[0m $1"
    fi
}

start_time=$(date)

# The tests
tests() {
    echo "resolve link:"

    [ $(resolve_link "foo" "bar") = "$PW_WIKI_DIR/bar.txt" ]
    assert "context at root level"

    [ $(resolve_link "" "cool") = "$PW_WIKI_DIR/cool.txt" ]
    assert "no context"

    [ $(resolve_link "foo/bar" "nice") = "$PW_WIKI_DIR/foo/nice.txt" ]
    assert "context at one level deep"

    [ $(resolve_link "foo/bar/" "nice") = "$PW_WIKI_DIR/foo/bar/nice.txt" ]
    assert "directory context"

    [ $(resolve_link "ignored/nope/" "/athome") = "$PW_WIKI_DIR/athome.txt" ]
    assert "ignored context"

    [ $(resolve_link "$PW_WIKI_DIR/my/file" "other") = "$PW_WIKI_DIR/my/other.txt" ]
    assert "wiki directory in context"
}

time tests

end_time=$(date)

echo ""
echo "Tests started : $start_time"
echo "Tests ended   : $end_time"
