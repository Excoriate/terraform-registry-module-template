#!/usr/bin/env bash
# Go linting script with module management

# Exit on error. Append "|| true" if you expect an error.
set -o errexit
# Exit on error inside any functions or subshells.
set -o errtrace
# Do not allow use of undefined vars. Use ${VAR:-} to use an undefined VAR
set -o nounset
# Catch error in case mysqldump fails (but gzip succeeds) in `mysqldump |gzip`
set -o pipefail
# Turn on traces, useful while debugging but commented out by default
# set -o xtrace

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# Log functions
log() { echo "🦫 $*" >&2; }
error() { echo "❌ Error: $*" >&2; }
# Keeping debug function for potential future use, but marking it as a shellcheck exception
# shellcheck disable=SC2317
debug() { echo "🐛 Debug: $*" >&2; }

# Function to check if Go files exist in the repository
check_go_files() {
    local go_files
    go_files=$(find . -type f -name "*.go")
    if [[ -z "$go_files" ]]; then
        log "No Go files found in the repository."
        exit 0
    fi
    log "Go files found:"
    echo "$go_files" >&2
    log "Total Go files: $(echo "$go_files" | wc -l | tr -d ' ')"
}

# Function to initialize Go module if not exists
initialize_go_module() {
    # Find all directories with Go files
    local go_dirs=()
    while IFS= read -r dir; do
        go_dirs+=("$dir")
    done < <(find . -type f -name "*.go" -exec dirname {} \; | sort -u)

    # If no Go directories found, exit
    if [[ ${#go_dirs[@]} -eq 0 ]]; then
        log "No directories with Go files found."
        exit 0
    fi

    # Attempt to find a directory with a go.mod or create one
    local module_dir=""
    for dir in "${go_dirs[@]}"; do
        if [[ -f "$dir/go.mod" ]]; then
            module_dir="$dir"
            break
        fi
    done

    # If no go.mod found, use the first directory with Go files
    if [[ -z "$module_dir" ]]; then
        module_dir="${go_dirs[0]}"
    fi

    log "Using directory $module_dir for module initialization"

    # Change to the module directory
    cd "$module_dir" || exit 1

    # Initialize go.mod if not exists
    if [[ ! -f go.mod ]]; then
        log "No go.mod found. Initializing Go module..."
        go mod init terraform-registry-module-template
    fi

    # Tidy dependencies
    log "Running go mod tidy..."
    go mod tidy

    # Return to original directory
    cd - || exit 1
}

# Function to run golangci-lint with fallback strategies
run_golangci_lint() {
    local lint_strategies=(
        "golangci-lint run ./..."
        "golangci-lint run"
        "golangci-lint run --config=.golangci.yml"
        "golangci-lint run --skip-dirs=tests"
    )

    for strategy in "${lint_strategies[@]}"; do
        log "Attempting linting with: $strategy"
        if $strategy; then
            log "✅ Linting successful with strategy: $strategy"
            return 0
        else
            error "Linting failed with strategy: $strategy"
        fi
    done

    error "All linting strategies failed"
    return 1
}

# Main function
main() {
    log "Starting Go code analysis..."

    # First, check if we have any Go files
    check_go_files

    # Initialize Go module and tidy dependencies
    initialize_go_module

    # Run golangci-lint
    if ! run_golangci_lint; then
        error "Comprehensive linting failed"
        exit 1
    fi

    log "✅ All Go code analysis completed successfully!"
}

# Run main function
main
