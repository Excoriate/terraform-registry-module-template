#!/bin/sh
# Terraform Linting Script with TFLint
# Supports module-specific and repository-wide linting with optional Nix environment
# Follows Google Shell Style Guide and shellcheck best practices

# Fail on any error and treat unset variables as an error
set -eu

# Global variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MODULES_DIR="${PROJECT_ROOT}/modules"
EXAMPLES_DIR="${PROJECT_ROOT}/examples"

# Default values
USE_NIX=false
TARGET_MODULE=""
VERBOSE=false

# Logging functions with consistent formatting
log() {
    message="${1}"
    echo "🔍 ${message}"
}

info() {
    message="${1}"
    echo "ℹ️  ${message}"
}

success() {
    message="${1}"
    echo "✅ ${message}"
}

error() {
    message="${1}"
    echo "❌ ${message}" >&2
}

warning() {
    message="${1}"
    echo "⚠️  ${message}"
}

# Display usage information
usage() {
    cat << EOF
Usage: ${0} [OPTIONS]

Terraform Linting Script with TFLint Support

OPTIONS:
    --module MODULE     Lint specific module (e.g., 'default', 'my-module')
    --nix              Use Nix development environment
    --verbose          Enable verbose output
    --help             Display this help message

EXAMPLES:
    ${0}                           # Lint all modules and examples
    ${0} --module default          # Lint specific module and its examples
    ${0} --nix                     # Lint all using Nix environment
    ${0} --module default --nix    # Lint specific module using Nix

DESCRIPTION:
    This script discovers and lints Terraform configurations using TFLint.
    It can operate on all modules/examples or target a specific module.
    Supports both local and Nix development environments.
EOF
}

# Execute TFLint command with proper error handling
execute_tflint() {
    target_dir="${1}"
    use_nix="${2:-false}"

    if [ ! -d "${target_dir}" ]; then
        error "Directory not found: ${target_dir}"
        return 1
    fi

    if [ ! -f "${target_dir}/.tflint.hcl" ]; then
        warning "No .tflint.hcl found in ${target_dir}, skipping"
        return 0
    fi

    info "Linting directory: ${target_dir}"

    # Change to target directory
    original_dir="$(pwd)"
    cd "${target_dir}" || {
        error "Failed to change to directory: ${target_dir}"
        return 1
    }

    # Execute TFLint commands
    exit_code=0
    if [ "${use_nix}" = "true" ]; then
        if [ "${VERBOSE}" = "true" ]; then
            log "Executing: nix develop --command tflint --init"
        fi
        nix develop "${PROJECT_ROOT}" --impure \
            --extra-experimental-features nix-command \
            --extra-experimental-features flakes \
            --command sh -c 'tflint --init && tflint --recursive' || exit_code=$?
    else
        if [ "${VERBOSE}" = "true" ]; then
            log "Executing: tflint --init && tflint --recursive"
        fi
        tflint --init && tflint --recursive || exit_code=$?
    fi

    # Return to original directory
    cd "${original_dir}" || {
        error "Failed to return to original directory"
        return 1
    }

    if [ ${exit_code} -eq 0 ]; then
        success "Linting completed successfully for ${target_dir}"
    else
        error "Linting failed for ${target_dir}"
    fi

    return ${exit_code}
}

# Discover directories with .tflint.hcl files
discover_tflint_directories() {
    base_dirs="${MODULES_DIR} ${EXAMPLES_DIR}"

    for base_dir in ${base_dirs}; do
        if [ -d "${base_dir}" ]; then
            find "${base_dir}" -type f -name ".tflint.hcl" 2>/dev/null | while read -r tflint_file; do
                dirname "${tflint_file}"
            done
        fi
    done | sort -u
}

# Lint all discovered directories
lint_all_directories() {
    use_nix="${1:-false}"
    failed_dirs=""
    success_count=0
    total_count=0

    log "Discovering Terraform modules and examples with .tflint.hcl files..."

    # Create temporary file to store directories
    temp_file="$(mktemp)"
    discover_tflint_directories > "${temp_file}"

    # Count directories
    total_count="$(wc -l < "${temp_file}" | tr -d ' ')"

    if [ "${total_count}" -eq 0 ]; then
        warning "No directories with .tflint.hcl files found"
        rm -f "${temp_file}"
        return 0
    fi

    log "Found ${total_count} directories to lint"

    while read -r dir; do
        if [ -n "${dir}" ]; then
            if execute_tflint "${dir}" "${use_nix}"; then
                success_count=$((success_count + 1))
            else
                if [ -z "${failed_dirs}" ]; then
                    failed_dirs="${dir}"
                else
                    failed_dirs="${failed_dirs} ${dir}"
                fi
            fi
        fi
    done < "${temp_file}"

    rm -f "${temp_file}"

    # Summary
    echo ""
    log "Linting Summary:"
    success "Successfully linted: ${success_count}/${total_count} directories"

    if [ -n "${failed_dirs}" ]; then
        error "Failed directories:"
        for failed_dir in ${failed_dirs}; do
            echo "   • ${failed_dir}"
        done
        return 1
    fi

    return 0
}

# Lint specific module and its examples
lint_module() {
    module_name="${1}"
    use_nix="${2:-false}"
    failed_dirs=""
    success_count=0
    total_count=0

    log "Linting module: ${module_name}"

    # Lint main module directory
    module_dir="${MODULES_DIR}/${module_name}"
    if [ -d "${module_dir}" ]; then
        total_count=$((total_count + 1))
        if execute_tflint "${module_dir}" "${use_nix}"; then
            success_count=$((success_count + 1))
        else
            failed_dirs="${module_dir}"
        fi
    else
        warning "Module directory not found: ${module_dir}"
    fi

    # Lint example subdirectories for the module
    examples_base="${EXAMPLES_DIR}/${module_name}"
    if [ -d "${examples_base}" ]; then
        log "Linting example subdirectories for module: ${module_name}"

        # Create temporary file for example directories
        temp_file="$(mktemp)"
        find "${examples_base}" -type f -name ".tflint.hcl" -exec dirname {} \; 2>/dev/null | sort -u > "${temp_file}"

        while read -r example_dir; do
            if [ -n "${example_dir}" ]; then
                total_count=$((total_count + 1))
                info "Linting example directory: ${example_dir}"
                if execute_tflint "${example_dir}" "${use_nix}"; then
                    success_count=$((success_count + 1))
                else
                    if [ -z "${failed_dirs}" ]; then
                        failed_dirs="${example_dir}"
                    else
                        failed_dirs="${failed_dirs} ${example_dir}"
                    fi
                fi
            fi
        done < "${temp_file}"

        if [ ! -s "${temp_file}" ]; then
            warning "No example directories with .tflint.hcl found for module: ${module_name}"
        fi

        rm -f "${temp_file}"
    else
        warning "Examples directory not found: ${examples_base}"
    fi

    # Summary
    echo ""
    log "Module Linting Summary for '${module_name}':"
    success "Successfully linted: ${success_count}/${total_count} directories"

    if [ -n "${failed_dirs}" ]; then
        error "Failed directories:"
        for failed_dir in ${failed_dirs}; do
            echo "   • ${failed_dir}"
        done
        return 1
    fi

    return 0
}

# Parse command line arguments
parse_arguments() {
    while [ $# -gt 0 ]; do
        case "${1}" in
            --module)
                if [ -n "${2:-}" ]; then
                    TARGET_MODULE="${2}"
                    shift 2
                else
                    error "Error: --module requires a module name"
                    usage
                    exit 1
                fi
                ;;
            --nix)
                USE_NIX=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                error "Unknown option: ${1}"
                usage
                exit 1
                ;;
        esac
    done
}

# Main execution function
main() {
    parse_arguments "$@"

    # Validate environment
    if [ "${USE_NIX}" = "true" ]; then
        if ! command -v nix >/dev/null 2>&1; then
            error "Nix is not available but --nix flag was specified"
            exit 1
        fi
        log "Using Nix development environment"
    else
        if ! command -v tflint >/dev/null 2>&1; then
            error "TFLint is not available. Please install TFLint or use --nix flag"
            exit 1
        fi
    fi

    # Execute linting based on target
    if [ -n "${TARGET_MODULE}" ]; then
        lint_module "${TARGET_MODULE}" "${USE_NIX}"
    else
        lint_all_directories "${USE_NIX}"
    fi
}

# Execute main function with all arguments
main "$@"
