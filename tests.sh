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

testitem() {
    ASSERT_INDENT=2
    echo ""
    echo "$1:"
}

list() {
    printf "%s\n" "$@"
}

start_time=$(date)

PIKKUWIKI_DIR="examplewiki"

# The tests
tests() {
    local expected_files

    testitem "resolve link"

    [ $(run_pikkuwiki resolve "foo" "bar") = "$PIKKUWIKI_DIR/bar.txt" ]
    assert "context at root level"

    [ $(run_pikkuwiki resolve "" "cool") = "$PIKKUWIKI_DIR/cool.txt" ]
    assert "no context"

    [ $(run_pikkuwiki resolve "foo/bar" "nice") = "$PIKKUWIKI_DIR/foo/nice.txt" ]
    assert "context at one level deep"

    [ $(run_pikkuwiki resolve "foo/bar/" "nice") = "$PIKKUWIKI_DIR/foo/bar/nice.txt" ]
    assert "directory context"

    [ $(run_pikkuwiki resolve "ignored/nope/" "/athome") = "$PIKKUWIKI_DIR/athome.txt" ]
    assert "ignored context"

    [ $(run_pikkuwiki resolve "$PIKKUWIKI_DIR/my/file" "other") = "$PIKKUWIKI_DIR/my/other.txt" ]
    assert "wiki directory in context"

    testitem "filename to link"

    [ $(filename_to_link "$PIKKUWIKI_DIR/foobar.txt") = "foobar" ]
    assert "root file"

    [ $(filename_to_link "$PIKKUWIKI_DIR/foo/bar.txt") = "foo/bar" ]
    assert "sub directory file"

    testitem "text files"

    expected_files=$(list \
        "examplewiki/Project/codeproject1.txt" \
        "examplewiki/Project/list.txt" \
        "examplewiki/Project/codeproject2.txt" \
        "examplewiki/groceries.txt" \
        "examplewiki/Index.txt" \
        "examplewiki/todo.txt" \
    )
    [ "$(text_files $PIKKUWIKI_DIR)" = "$expected_files" ]
    assert "all files"

    testitem "find"

    expected_files=$(list \
        "examplewiki/groceries.txt" \
        "examplewiki/Project/codeproject1.txt" \
        "examplewiki/Project/codeproject2.txt" \
        "examplewiki/Project/thesis.txt" \
        "examplewiki/todo.txt" \
    )
    [ "$(run_pikkuwiki find)" = "$expected_files" ]
    assert "find all"

    expected_files=$(list \
        "examplewiki/Project/codeproject1.txt" \
        "examplewiki/Project/codeproject2.txt" \
    )
    [ "$(run_pikkuwiki find -l Project/list -p code)" = "$expected_files" ]
    assert "find from Project/list with filter 'code'"

    [ "$(run_pikkuwiki find -l Project/codeproject1)" = "examplewiki/todo.txt" ]
    assert "find from Project/codeproject1"

    expected_files=$(list \
        "examplewiki/Project/codeproject1.txt" \
        "examplewiki/Project/codeproject2.txt" \
        "examplewiki/Project/thesis.txt" \
        "examplewiki/todo.txt" \
    )
    [ "$(run_pikkuwiki find -l Project)" = "$expected_files" ]
    assert "find from Project"
}

time tests

end_time=$(date)

echo ""
echo "Tests started : $start_time"
echo "Tests ended   : $end_time"

