#!/bin/sh

# Program that is to be tested
pikkuwiki() {
    ./pikkuwiki.sh "$@"
}

# Allow errors to collect test results
set +e

# This value will be set to non-zero if any of the tests fail
TESTS_SUCCESS=0

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
        printf "\e[1;32mSuccess:\e[0m %s\n" "$1"
    else
        TESTS_SUCCESS=1
        printf "\e[0;31mFailure:\e[0m %s\n" "$1"
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

export PIKKUWIKI_DIR="examplewiki"
export PW_DEFAULT_PAGE="index"

# The tests
tests() {
    local expected_files

    testitem "resolve"

    [ "$(pikkuwiki resolve)" = "$PIKKUWIKI_DIR/$PW_DEFAULT_PAGE.txt" ]
    assert "empty context & link"

    [ "$(pikkuwiki resolve "$PIKKUWIKI_DIR/" "")" = "$PIKKUWIKI_DIR/$PW_DEFAULT_PAGE.txt" ]
    assert "wiki dir as context"

    [ "$(pikkuwiki resolve "foo/bar")" = "$PIKKUWIKI_DIR/foo/$PW_DEFAULT_PAGE.txt" ]
    assert "empty link, sub directory #1"

    [ "$(pikkuwiki resolve "foo/bar/")" = "$PIKKUWIKI_DIR/foo/bar/$PW_DEFAULT_PAGE.txt" ]
    assert "empty link, sub directory #2"

    [ "$(pikkuwiki resolve "foo" "bar")" = "$PIKKUWIKI_DIR/bar.txt" ]
    assert "context at root level"

    [ "$(pikkuwiki resolve "" "cool")" = "$PIKKUWIKI_DIR/cool.txt" ]
    assert "no context"

    [ "$(pikkuwiki resolve "foo/bar" "nice")" = "$PIKKUWIKI_DIR/foo/nice.txt" ]
    assert "context at one level deep"

    [ "$(pikkuwiki resolve "foo/bar/" "nice")" = "$PIKKUWIKI_DIR/foo/bar/nice.txt" ]
    assert "directory context"

    [ "$(pikkuwiki resolve "ignored/nope/" "/athome")" = "$PIKKUWIKI_DIR/athome.txt" ]
    assert "ignored context"

    [ "$(pikkuwiki resolve "$PIKKUWIKI_DIR/my/file" "other")" = "$PIKKUWIKI_DIR/my/other.txt" ]
    assert "wiki directory in context"

    testitem "find"

    expected_files=$(list \
        "$PIKKUWIKI_DIR/groceries.txt" \
        "$PIKKUWIKI_DIR/index.txt" \
        "$PIKKUWIKI_DIR/Project/codeproject1.txt" \
        "$PIKKUWIKI_DIR/Project/codeproject2.txt" \
        "$PIKKUWIKI_DIR/Project/list.txt" \
        "$PIKKUWIKI_DIR/todo.txt" \
    )
    [ "$(pikkuwiki find)" = "$expected_files" ]
    assert "find all"

    expected_files=$(list \
        "$PIKKUWIKI_DIR/Project/codeproject1.txt" \
        "$PIKKUWIKI_DIR/Project/codeproject2.txt" \
    )
    [ "$(pikkuwiki find -p code)" = "$expected_files" ]
    assert "find 'code'"

    testitem "show"

    expected_files=$(list \
        "$PIKKUWIKI_DIR/Project/codeproject1.txt" \
        "$PIKKUWIKI_DIR/Project/codeproject2.txt" \
    )
    [ "$(pikkuwiki show -l Project/list -p code)" = "$expected_files" ]
    assert "show from Project/list with filter 'code'"

    [ "$(pikkuwiki show -l Project/codeproject1)" = "$PIKKUWIKI_DIR/todo.txt" ]
    assert "show from Project/codeproject1"
}

time tests

end_time=$(date)

echo ""
echo "Tests started : $start_time"
echo "Tests ended   : $end_time"

exit $TESTS_SUCCESS
