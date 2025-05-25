#!/bin/sh
# Comprehensive formatting script for Terraform, Go, and YAML files
# Supports selective formatting with optional Nix environment
# Follows Google Shell Style Guide and shellcheck best practices

# Fail on any error and treat unset variables as an error
set -eu

# Global variables
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Default values
USE_NIX=false
FORMAT_TERRAFORM=false
FORMAT_GO=false
FORMAT_YAML=false
VERBOSE=false

# Logging functions with consistent formatting
log() {
    message="${1}"
    echo "🔧 ${message}"
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

Comprehensive Formatting Script for Terraform, Go, and YAML Files

OPTIONS:
    --terraform        Format Terraform files (.tf, .tfvars)
    --go              Format Go files (.go)
    --yaml            Format YAML files (.yml, .yaml)
    --all             Format all supported file types
    --nix             Use Nix development environment
    --verbose         Enable verbose output
    --help            Display this help message

EXAMPLES:
    ${0} --all                    # Format all file types
    ${0} --terraform              # Format only Terraform files
    ${0} --go --yaml              # Format Go and YAML files
    ${0} --terraform --nix        # Format Terraform files using Nix

DESCRIPTION:
    This script provides comprehensive formatting for multiple file types
    commonly used in Terraform projects. It can operate using local tools
    or within a Nix development environment for reproducible formatting.
EOF
}

# Format Terraform files using terraform fmt
format_terraform() {
    use_nix="${1:-false}"

    log "Formatting Terraform files..."

    # Change to project root for terraform fmt
    original_dir="$(pwd)"
    cd "${PROJECT_ROOT}" || {
        error "Failed to change to project root: ${PROJECT_ROOT}"
        return 1
    }

    exit_code=0
    if [ "${use_nix}" = "true" ]; then
        if [ "${VERBOSE}" = "true" ]; then
            log "Executing: nix run nixpkgs#terraform -- fmt -recursive"
        fi
        nix run nixpkgs#terraform -- fmt -recursive || exit_code=$?
    else
        if [ "${VERBOSE}" = "true" ]; then
            log "Executing: terraform fmt -recursive"
        fi
        terraform fmt -recursive || exit_code=$?
    fi

    # Return to original directory
    cd "${original_dir}" || {
        error "Failed to return to original directory"
        return 1
    }

    if [ ${exit_code} -eq 0 ]; then
        success "Terraform files formatted successfully"
    else
        error "Terraform formatting failed"
    fi

    return ${exit_code}
}

# Format Go files using gofmt and goimports
format_go() {
    use_nix="${1:-false}"

    log "Formatting Go files..."

    # Find Go files
    temp_file="$(mktemp)"
    find "${PROJECT_ROOT}" -name "*.go" -type f > "${temp_file}"

    if [ ! -s "${temp_file}" ]; then
        info "No Go files found to format"
        rm -f "${temp_file}"
        return 0
    fi

    go_file_count="$(wc -l < "${temp_file}" | tr -d ' ')"
    log "Found ${go_file_count} Go files to format"

    exit_code=0
    if [ "${use_nix}" = "true" ]; then
        # Format with gofmt
        if [ "${VERBOSE}" = "true" ]; then
            log "Executing: nix run nixpkgs#go -- fmt"
        fi
        while read -r go_file; do
            if [ -n "${go_file}" ]; then
                nix run nixpkgs#go -- fmt "${go_file}" || exit_code=$?
            fi
        done < "${temp_file}"

        # Format with goimports if available
        if command -v goimports >/dev/null 2>&1; then
            if [ "${VERBOSE}" = "true" ]; then
                log "Executing: goimports -w"
            fi
            while read -r go_file; do
                if [ -n "${go_file}" ]; then
                    goimports -w "${go_file}" || exit_code=$?
                fi
            done < "${temp_file}"
        fi
    else
        # Format with gofmt
        if [ "${VERBOSE}" = "true" ]; then
            log "Executing: gofmt -w"
        fi
        while read -r go_file; do
            if [ -n "${go_file}" ]; then
                gofmt -w "${go_file}" || exit_code=$?
            fi
        done < "${temp_file}"

        # Format with goimports if available
        if command -v goimports >/dev/null 2>&1; then
            if [ "${VERBOSE}" = "true" ]; then
                log "Executing: goimports -w"
            fi
            while read -r go_file; do
                if [ -n "${go_file}" ]; then
                    goimports -w "${go_file}" || exit_code=$?
                fi
            done < "${temp_file}"
        fi
    fi

    rm -f "${temp_file}"

    if [ ${exit_code} -eq 0 ]; then
        success "Go files formatted successfully"
    else
        error "Go formatting failed"
    fi

    return ${exit_code}
}

# Format YAML files using yamlfmt
format_yaml() {
    use_nix="${1:-false}"

    log "Formatting YAML files..."

    # Find YAML files
    temp_file="$(mktemp)"
    find "${PROJECT_ROOT}" \( -name "*.yml" -o -name "*.yaml" \) -type f > "${temp_file}"

    if [ ! -s "${temp_file}" ]; then
        info "No YAML files found to format"
        rm -f "${temp_file}"
        return 0
    fi

    yaml_file_count="$(wc -l < "${temp_file}" | tr -d ' ')"
    log "Found ${yaml_file_count} YAML files to format"

    exit_code=0
    if [ "${use_nix}" = "true" ]; then
        if [ "${VERBOSE}" = "true" ]; then
            log "Executing: nix run nixpkgs#yamlfmt"
        fi
        while read -r yaml_file; do
            if [ -n "${yaml_file}" ]; then
                nix run nixpkgs#yamlfmt -- -w "${yaml_file}" || exit_code=$?
            fi
        done < "${temp_file}"
    else
        if [ "${VERBOSE}" = "true" ]; then
            log "Executing: yamlfmt -w"
        fi
        while read -r yaml_file; do
            if [ -n "${yaml_file}" ]; then
                yamlfmt -w "${yaml_file}" || exit_code=$?
            fi
        done < "${temp_file}"
    fi

    rm -f "${temp_file}"

    if [ ${exit_code} -eq 0 ]; then
        success "YAML files formatted successfully"
    else
        error "YAML formatting failed"
    fi

    return ${exit_code}
}

# Validate required tools are available
validate_tools() {
    use_nix="${1:-false}"
    missing_tools=""

    if [ "${use_nix}" = "true" ]; then
        if ! command -v nix >/dev/null 2>&1; then
            missing_tools="nix"
        fi
    else
        if [ "${FORMAT_TERRAFORM}" = "true" ] && ! command -v terraform >/dev/null 2>&1; then
            if [ -z "${missing_tools}" ]; then
                missing_tools="terraform"
            else
                missing_tools="${missing_tools} terraform"
            fi
        fi

        if [ "${FORMAT_GO}" = "true" ] && ! command -v go >/dev/null 2>&1; then
            if [ -z "${missing_tools}" ]; then
                missing_tools="go"
            else
                missing_tools="${missing_tools} go"
            fi
        fi

        if [ "${FORMAT_YAML}" = "true" ] && ! command -v yamlfmt >/dev/null 2>&1; then
            if [ -z "${missing_tools}" ]; then
                missing_tools="yamlfmt"
            else
                missing_tools="${missing_tools} yamlfmt"
            fi
        fi
    fi

    if [ -n "${missing_tools}" ]; then
        error "Missing required tools: ${missing_tools}"
        if [ "${use_nix}" = "false" ]; then
            info "Consider using --nix flag to use Nix environment"
        fi
        return 1
    fi

    return 0
}

# Parse command line arguments
parse_arguments() {
    while [ $# -gt 0 ]; do
        case "${1}" in
            --terraform)
                FORMAT_TERRAFORM=true
                shift
                ;;
            --go)
                FORMAT_GO=true
                shift
                ;;
            --yaml)
                FORMAT_YAML=true
                shift
                ;;
            --all)
                FORMAT_TERRAFORM=true
                FORMAT_GO=true
                FORMAT_YAML=true
                shift
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

    # If no specific format options are provided, default to all
    if [ "${FORMAT_TERRAFORM}" = "false" ] && [ "${FORMAT_GO}" = "false" ] && [ "${FORMAT_YAML}" = "false" ]; then
        FORMAT_TERRAFORM=true
        FORMAT_GO=true
        FORMAT_YAML=true
    fi
}

# Main execution function
main() {
    parse_arguments "$@"

    # Validate tools
    if ! validate_tools "${USE_NIX}"; then
        exit 1
    fi

    if [ "${USE_NIX}" = "true" ]; then
        log "Using Nix development environment"
    fi

    # Track overall success
    overall_exit_code=0

    # Format files based on selected options
    if [ "${FORMAT_TERRAFORM}" = "true" ]; then
        if ! format_terraform "${USE_NIX}"; then
            overall_exit_code=1
        fi
    fi

    if [ "${FORMAT_GO}" = "true" ]; then
        if ! format_go "${USE_NIX}"; then
            overall_exit_code=1
        fi
    fi

    if [ "${FORMAT_YAML}" = "true" ]; then
        if ! format_yaml "${USE_NIX}"; then
            overall_exit_code=1
        fi
    fi

    # Summary
    echo ""
    if [ ${overall_exit_code} -eq 0 ]; then
        success "All formatting operations completed successfully"
    else
        error "Some formatting operations failed"
    fi

    exit ${overall_exit_code}
}

# Execute main function with all arguments
main "$@"
