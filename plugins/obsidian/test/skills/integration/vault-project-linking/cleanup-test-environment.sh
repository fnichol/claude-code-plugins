#!/bin/bash
# cleanup-test-environment.sh
#
# Removes isolated test environment created by setup-test-environment.sh.
# Safe to run - only touches temporary directories in /tmp/.

set -euo pipefail

# Function to display usage
usage() {
    cat <<EOF
Usage: $0 <test-session-id>

Removes test environment for the specified session ID.

Example:
  $0 test-1731700000-12345

The session ID is output by setup-test-environment.sh when you run it.
You can also find session IDs by looking at /tmp/test-session-*.env files.

Options:
  --list    List available test sessions
  --all     Clean up all test sessions
  -h        Show this help message

EOF
    exit 1
}

# Function to list available test sessions
list_sessions() {
    echo "Available test sessions:"
    echo ""

    if ls /tmp/test-session-*.env 2>/dev/null 1>&2; then
        for envfile in /tmp/test-session-*.env; do
            if [ -f "$envfile" ]; then
                # Source the env file to get session info
                source "$envfile"
                echo "Session: ${TEST_SESSION}"
                echo "  Vault: ${TEST_VAULT}"
                echo "  Workdir: ${TEST_WORKDIR}"

                # Check if directories still exist
                if [ -d "${TEST_VAULT}" ] && [ -d "${TEST_WORKDIR}" ]; then
                    echo "  Status: Active (directories exist)"
                elif [ ! -d "${TEST_VAULT}" ] && [ ! -d "${TEST_WORKDIR}" ]; then
                    echo "  Status: Cleaned (directories removed)"
                else
                    echo "  Status: Partial (some directories exist)"
                fi
                echo ""
            fi
        done
    else
        echo "  No test sessions found."
        echo ""
    fi
}

# Function to cleanup a specific session
cleanup_session() {
    local session_id=$1
    local envfile="/tmp/test-session-${session_id}.env"

    if [ ! -f "$envfile" ]; then
        echo "❌ Error: Test session '${session_id}' not found."
        echo ""
        echo "Available sessions:"
        list_sessions
        exit 1
    fi

    # Source the environment file
    source "$envfile"

    echo "Cleaning up test session: ${TEST_SESSION}"
    echo ""

    # Remove test vault
    if [ -d "${TEST_VAULT}" ]; then
        echo "Removing test vault: ${TEST_VAULT}"
        rm -rf "${TEST_VAULT}"
        echo "  ✓ Removed"
    else
        echo "Test vault already removed: ${TEST_VAULT}"
    fi

    # Remove test working directory
    if [ -d "${TEST_WORKDIR}" ]; then
        echo "Removing test working directory: ${TEST_WORKDIR}"
        rm -rf "${TEST_WORKDIR}"
        echo "  ✓ Removed"
    else
        echo "Test working directory already removed: ${TEST_WORKDIR}"
    fi

    # Remove session environment file
    echo "Removing session file: ${envfile}"
    rm -f "${envfile}"
    echo "  ✓ Removed"

    echo ""
    echo "✅ Cleanup complete for session: ${TEST_SESSION}"
}

# Function to cleanup all sessions
cleanup_all() {
    echo "Cleaning up all test sessions..."
    echo ""

    if ! ls /tmp/test-session-*.env 2>/dev/null 1>&2; then
        echo "No test sessions found."
        return
    fi

    local count=0
    for envfile in /tmp/test-session-*.env; do
        if [ -f "$envfile" ]; then
            source "$envfile"
            echo "Cleaning session: ${TEST_SESSION}"

            [ -d "${TEST_VAULT}" ] && rm -rf "${TEST_VAULT}"
            [ -d "${TEST_WORKDIR}" ] && rm -rf "${TEST_WORKDIR}"
            rm -f "${envfile}"

            count=$((count + 1))
        fi
    done

    echo ""
    echo "✅ Cleaned up ${count} test session(s)."
}

# Parse arguments
if [ $# -eq 0 ]; then
    usage
fi

case "$1" in
    --list)
        list_sessions
        ;;
    --all)
        cleanup_all
        ;;
    -h|--help)
        usage
        ;;
    *)
        # Assume it's a session ID
        TEST_SESSION=$1
        cleanup_session "$TEST_SESSION"
        ;;
esac
