#!/bin/sh
# Comprehensive formatting script for Terraform, Go, and YAML files
# Supports selective formatting with optional Nix environment
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
FORMAT_TERRAFORM=false
FORMAT_GO=false
FORMAT_YAML=false
VERBOSE=false
TF_CHECK_MODE=false
TF_MODULE=""
TF_ALL_DIRS=false
TF_DISCOVER=false

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

TERRAFORM-SPECIFIC OPTIONS:
    --tf-check        Check Terraform formatting without modifying files
    --tf-module MOD   Format specific module (e.g., 'default', 'my-module')
    --tf-all-dirs     Format across modules/, examples/, and tests/ directories
    --tf-discover     Discover and list Terraform files without formatting

EXAMPLES:
    ${0} --all                    # Format all file types
    ${0} --terraform              # Format only Terraform files
    ${0} --terraform --tf-check   # Check Terraform formatting only
    ${0} --terraform --tf-module default  # Format specific module
    ${0} --go --yaml              # Format Go and YAML files
    ${0} --terraform --nix        # Format Terraform files using Nix

DESCRIPTION:
    This script provides comprehensive formatting for multiple file types
    commonly used in Terraform projects. It can operate using local tools
    or within a Nix development environment for reproducible formatting.
EOF
}

# Discover Terraform files in a directory
discover_terraform_files() {
    search_dir="${1}"

    if [ ! -d "${search_dir}" ]; then
        info "Directory not found: ${search_dir}"
        return 1
    fi

    find "${search_dir}" -type f \( -name "*.tf" -o -name "*.tfvars" \) 2>/dev/null | sort || true
}

# Format Terraform files using terraform fmt
format_terraform() {
    use_nix="${1:-false}"
    check_mode="${2:-false}"
    target_dir="${3:-${PROJECT_ROOT}}"

    if [ "${check_mode}" = "true" ]; then
        log "Checking Terraform file formatting in: ${target_dir}"
    else
        log "Formatting Terraform files in: ${target_dir}"
    fi

    # Change to target directory for terraform fmt
    original_dir="$(pwd)"
    cd "${target_dir}" || {
        error "Failed to change to directory: ${target_dir}"
        return 1
    }

    exit_code=0
    if [ "${use_nix}" = "true" ]; then
        if [ "${check_mode}" = "true" ]; then
            if [ "${VERBOSE}" = "true" ]; then
                log "Executing: nix run nixpkgs#terraform -- fmt -recursive -check"
            fi
            nix run nixpkgs#terraform -- fmt -recursive -check || exit_code=$?
        else
            if [ "${VERBOSE}" = "true" ]; then
                log "Executing: nix run nixpkgs#terraform -- fmt -recursive"
            fi
            nix run nixpkgs#terraform -- fmt -recursive || exit_code=$?
        fi
    else
        if [ "${check_mode}" = "true" ]; then
            if [ "${VERBOSE}" = "true" ]; then
                log "Executing: terraform fmt -recursive -check"
            fi
            terraform fmt -recursive -check || exit_code=$?
        else
            if [ "${VERBOSE}" = "true" ]; then
                log "Executing: terraform fmt -recursive"
            fi
            terraform fmt -recursive || exit_code=$?
        fi
    fi

    # Return to original directory
    cd "${original_dir}" || {
        error "Failed to return to original directory"
        return 1
    }

    if [ "${exit_code}" -eq 0 ]; then
        if [ "${check_mode}" = "true" ]; then
            success "Terraform files are correctly formatted in: ${target_dir}"
        else
            success "Terraform files formatted successfully in: ${target_dir}"
        fi
    else
        if [ "${check_mode}" = "true" ]; then
            error "Terraform files need formatting in: ${target_dir}"
        else
            error "Terraform formatting failed in: ${target_dir}"
        fi
    fi

    return "${exit_code}"
}

# Format specific Terraform module
format_terraform_module() {
    module_name="${1}"
    use_nix="${2:-false}"
    check_mode="${3:-false}"

    log "Processing Terraform module: ${module_name}"

    module_dir="${MODULES_DIR}/${module_name}"
    example_dir="${EXAMPLES_DIR}/${module_name}"
    has_errors=false

    # Format module directory
    if [ -d "${module_dir}" ]; then
        log "Processing module directory: ${module_dir}"
        if ! format_terraform "${use_nix}" "${check_mode}" "${module_dir}"; then
            has_errors=true
        fi
    else
        warning "Module directory not found: ${module_dir}"
    fi

    # Format example directory
    if [ -d "${example_dir}" ]; then
        log "Processing example directory: ${example_dir}"
        if ! format_terraform "${use_nix}" "${check_mode}" "${example_dir}"; then
            has_errors=true
        fi
    else
        info "Example directory not found: ${example_dir}"
    fi

    if [ "${has_errors}" = "true" ]; then
        return 1
    fi

    success "Module ${module_name} processing completed successfully"
    return 0
}

# Format all Terraform directories
format_terraform_all_directories() {
    use_nix="${1:-false}"
    check_mode="${2:-false}"

    log "Processing all Terraform directories"

    directories="${MODULES_DIR} ${EXAMPLES_DIR}"
    has_errors=false

    for dir in ${directories}; do
        if [ -d "${dir}" ]; then
            dir_name="$(basename "${dir}")"
            log "Processing ${dir_name}/ directory"

            if ! format_terraform "${use_nix}" "${check_mode}" "${dir}"; then
                has_errors=true
            fi
        else
            info "Directory not found: ${dir}"
        fi
    done

    if [ "${has_errors}" = "true" ]; then
        return 1
    fi

    success "All directories processed successfully"
    return 0
}

# Discover all Terraform files
discover_all_terraform_files() {
    log "Discovering all Terraform files in the repository"

    directories="${MODULES_DIR} ${EXAMPLES_DIR}"
    total_files=0

    for dir in ${directories}; do
        if [ -d "${dir}" ]; then
            dir_name="$(basename "${dir}")"
            log "Scanning ${dir_name}/ directory"

            files="$(discover_terraform_files "${dir}")"
            if [ -n "${files}" ]; then
                echo "${files}" | while read -r file; do
                    echo "   📄 ${file}"
                done
                file_count="$(echo "${files}" | wc -l | tr -d ' ')"
                total_files=$((total_files + file_count))
            fi
        fi
    done

    success "Discovery complete! Found ${total_files} Terraform files total"
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

    if [ "${exit_code}" -eq 0 ]; then
        success "Go files formatted successfully"
    else
        error "Go formatting failed"
    fi

    return "${exit_code}"
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

    if [ "${exit_code}" -eq 0 ]; then
        success "YAML files formatted successfully"
    else
        error "YAML formatting failed"
    fi

    return "${exit_code}"
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
            --tf-check)
                TF_CHECK_MODE=true
                FORMAT_TERRAFORM=true
                shift
                ;;
            --tf-module)
                if [ -n "${2:-}" ]; then
                    TF_MODULE="${2}"
                    FORMAT_TERRAFORM=true
                    shift 2
                else
                    error "Error: --tf-module requires a module name"
                    usage
                    exit 1
                fi
                ;;
            --tf-all-dirs)
                TF_ALL_DIRS=true
                FORMAT_TERRAFORM=true
                shift
                ;;
            --tf-discover)
                TF_DISCOVER=true
                FORMAT_TERRAFORM=true
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

    # Handle Terraform discovery mode
    if [ "${TF_DISCOVER}" = "true" ]; then
        discover_all_terraform_files
        return 0
    fi

    # Validate tools
    if ! validate_tools "${USE_NIX}"; then
        exit 1
    fi

    if [ "${USE_NIX}" = "true" ]; then
        log "Using Nix development environment"
    fi

    # Track overall success
    overall_exit_code=0

    # Handle Terraform formatting based on options
    if [ "${FORMAT_TERRAFORM}" = "true" ]; then
        if [ -n "${TF_MODULE}" ]; then
            # Format specific module
            if ! format_terraform_module "${TF_MODULE}" "${USE_NIX}" "${TF_CHECK_MODE}"; then
                overall_exit_code=1
            fi
        elif [ "${TF_ALL_DIRS}" = "true" ]; then
            # Format all directories
            if ! format_terraform_all_directories "${USE_NIX}" "${TF_CHECK_MODE}"; then
                overall_exit_code=1
            fi
        else
            # Default: format current directory and subdirectories
            if ! format_terraform "${USE_NIX}" "${TF_CHECK_MODE}"; then
                overall_exit_code=1
            fi
        fi
    fi

    # Handle other file types (only if not in Terraform-specific modes)
    if [ -z "${TF_MODULE}" ] && [ "${TF_ALL_DIRS}" = "false" ]; then
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
    fi

    # Summary
    echo ""
    if [ "${overall_exit_code}" -eq 0 ]; then
        success "All formatting operations completed successfully"
    else
        error "Some formatting operations failed"
    fi

    exit "${overall_exit_code}"
}

# Execute main function with all arguments
main "$@"
