#!/usr/bin/env bash
# shellcheck disable=SC2317

# Pre-Commit Hook Management Script
#
# This script provides functionality to manage pre-commit hooks for the repository.
# It follows Google's Bash Style Guide and provides reliable hook management.

# Strict error handling
set -euo pipefail

# Logging function with timestamp and color
log() {
    local -r level="${1}"
    local -r message="${2}"
    local -r timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    local color=""

    case "${level}" in
        INFO)    color="\033[0;32m" ;;  # Green
        WARNING) color="\033[0;33m" ;;  # Yellow
        ERROR)   color="\033[0;31m" ;;  # Red
        *)       color="\033[0m" ;;     # Default
    esac

    # shellcheck disable=SC2059
    printf "${color}[${level}] ${timestamp}: ${message}\033[0m\n" >&2
}

# Ensure pre-commit is installed
ensure_pre_commit_installed() {
    if ! command -v pre-commit &> /dev/null; then
        log ERROR "pre-commit is not installed. Installing via pip..."
        if ! pip3 install pre-commit; then
            log ERROR "Failed to install pre-commit. Please install manually."
            return 1
        fi
    fi
    log INFO "pre-commit is installed and ready."
}

# Install pre-commit hooks
# Exposed function 1: Initialize repository hooks
pc_init() {
    ensure_pre_commit_installed

    log INFO "Installing pre-commit hooks..."
    if ! pre-commit install; then
        log ERROR "Failed to install pre-commit hooks"
        return 1
    fi

    if ! pre-commit install --hook-type pre-commit; then
        log ERROR "Failed to install pre-commit hooks for commit stage"
        return 1
    fi

    if ! pre-commit install --hook-type pre-push; then
        log ERROR "Failed to install pre-commit hooks for pre-push stage"
        return 1
    fi

    log INFO "All pre-commit hooks installed successfully"
}

# Run pre-commit hooks on all files
# Exposed function 2: Run hooks across all files
pc_run() {
    log INFO "Running pre-commit hooks on all files..."
    if ! pre-commit run --all-files; then
        log ERROR "Pre-commit hooks failed on some files"
        return 1
    fi
    log INFO "Pre-commit hooks completed successfully"
}

# Main function for script execution
main() {
    local command="${1:-}"

    case "${command}" in
        init)
            pc_init
            ;;
        run)
            pc_run
            ;;
        *)
            log ERROR "Invalid command. Use 'init' or 'run'."
            exit 1
            ;;
    esac
}

# Allow sourcing for function access or direct script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
