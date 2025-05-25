#!/usr/bin/env bash
# Comprehensive formatting script for Terraform, Go, and YAML files
# Supports discovery, formatting, validation, and module-specific operations

# Fail on any error and treat unset variables as an error
set -euo pipefail

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
MODULES_DIR="${PROJECT_ROOT}/modules"
EXAMPLES_DIR="${PROJECT_ROOT}/examples"
TESTS_DIR="${PROJECT_ROOT}/tests"

# Logging functions with consistent formatting
log() {
    local message="${1}"
    echo "🎨 ${message}"
}

info() {
    local message="${1}"
    echo "ℹ️  ${message}"
}

success() {
    local message="${1}"
    echo "✅ ${message}"
}

error_exit() {
    local message="${1}"
    echo "❌ Error: ${message}" >&2
    exit 1
}

# Show usage information
show_usage() {
    cat << EOF
🎨 Comprehensive Formatting Script

USAGE:
    $(basename "$0") [OPTIONS] [FORMAT_TYPE]

FORMAT TYPES:
    --all                Format all file types (default)
    --terraform          Format only Terraform files
    --go                 Format only Go files
    --yaml               Format only YAML files

TERRAFORM OPTIONS:
    --tf-check           Check Terraform formatting without modifying files
    --tf-module MOD      Format specific module (e.g., 'default', 'aws-vpc')
    --tf-discover        Discover and list Terraform files without formatting
    --tf-all-dirs        Format across modules/, examples/, and tests/ directories

EXAMPLES:
    $(basename "$0") --terraform                    # Format all Terraform files
    $(basename "$0") --terraform --tf-module default  # Format specific module
    $(basename "$0") --terraform --tf-check           # Check formatting only
    $(basename "$0") --terraform --tf-discover        # Discover files only
    $(basename "$0") --go                           # Format Go files
    $(basename "$0") --yaml                         # Format YAML files

EOF
}

# Discover Terraform files in a directory
discover_terraform_files() {
    local search_dir="${1}"
    local files

    if [[ ! -d "${search_dir}" ]]; then
        info "Directory not found: ${search_dir}"
        return 1
    fi

    files=$(find "${search_dir}" -type f \( -name "*.tf" -o -name "*.tfvars" \) 2>/dev/null | sort || true)

    if [[ -z "${files}" ]]; then
        info "No Terraform files found in: ${search_dir}"
        return 1
    fi

    echo "${files}"
    return 0
}

# List discovered files with proper formatting
list_discovered_files() {
    local files="${1}"
    local prefix="${2:-📄}"

    echo "${files}" | while IFS= read -r file; do
        echo "   ${prefix} ${file}"
    done
}

# Format Terraform files in a directory
format_terraform_directory() {
    local target_dir="${1}"
    local check_mode="${2:-false}"
    local operation

    if [[ "${check_mode}" == "true" ]]; then
        operation="Checking"
    else
        operation="Formatting"
    fi

    log "${operation} Terraform files in: ${target_dir}"

    if [[ ! -d "${target_dir}" ]]; then
        error_exit "Directory not found: ${target_dir}"
    fi

    # Discover files first
    local files
    if ! files=$(discover_terraform_files "${target_dir}"); then
        info "No Terraform files to process in: ${target_dir}"
        return 0
    fi

    log "Found Terraform files:"
    list_discovered_files "${files}" "📄"

    # Change to target directory for terraform fmt
    local original_dir
    original_dir=$(pwd)
    cd "${target_dir}" || error_exit "Failed to change to directory: ${target_dir}"

    # Execute terraform fmt
    local fmt_args="-recursive"
    if [[ "${check_mode}" == "true" ]]; then
        fmt_args="${fmt_args} -check"
    fi

    local fmt_output
    local fmt_exit_code=0

    # Capture output and exit code
    if ! fmt_output=$(terraform fmt ${fmt_args} 2>&1); then
        fmt_exit_code=$?
    fi

    # Return to original directory
    cd "${original_dir}" || error_exit "Failed to return to original directory"

    # Handle results
    if [[ "${check_mode}" == "true" ]]; then
        if [[ ${fmt_exit_code} -eq 0 ]]; then
            success "All Terraform files are correctly formatted in: ${target_dir}"
        else
            echo "❌ Unformatted files found in: ${target_dir}"
            if [[ -n "${fmt_output}" ]]; then
                echo "${fmt_output}" | while IFS= read -r line; do
                    echo "   📄 ${line}"
                done
            fi
            return 1
        fi
    else
        if [[ ${fmt_exit_code} -eq 0 ]]; then
            success "Terraform files formatted successfully in: ${target_dir}"
        else
            error_exit "Terraform formatting failed in: ${target_dir}: ${fmt_output}"
        fi
    fi

    return 0
}

# Format specific module
format_terraform_module() {
    local module_name="${1}"
    local check_mode="${2:-false}"
    local operation

    if [[ "${check_mode}" == "true" ]]; then
        operation="Checking"
    else
        operation="Formatting"
    fi

    log "${operation} Terraform files for module: ${module_name}"

    local module_dir="${MODULES_DIR}/${module_name}"
    local example_dir="${EXAMPLES_DIR}/${module_name}"
    local has_errors=false

    # Format module directory
    if [[ -d "${module_dir}" ]]; then
        log "📂 Processing module directory: ${module_dir}"
        if ! format_terraform_directory "${module_dir}" "${check_mode}"; then
            has_errors=true
        fi
    else
        info "Module directory not found: ${module_dir}"
    fi

    # Format example directory
    if [[ -d "${example_dir}" ]]; then
        log "📂 Processing example directory: ${example_dir}"
        if ! format_terraform_directory "${example_dir}" "${check_mode}"; then
            has_errors=true
        fi
    else
        info "Example directory not found: ${example_dir}"
    fi

    if [[ "${has_errors}" == "true" ]]; then
        return 1
    fi

    success "Module ${module_name} processing completed successfully"
    return 0
}

# Format all directories (modules, examples, tests)
format_terraform_all_directories() {
    local check_mode="${1:-false}"
    local operation

    if [[ "${check_mode}" == "true" ]]; then
        operation="Checking"
    else
        operation="Formatting"
    fi

    log "${operation} all Terraform files across repository directories"
    log "📂 Target directories: modules/, examples/, tests/"

    local has_errors=false
    local directories=("${MODULES_DIR}" "${EXAMPLES_DIR}" "${TESTS_DIR}")

    for dir in "${directories[@]}"; do
        if [[ -d "${dir}" ]]; then
            local dir_name
            dir_name=$(basename "${dir}")
            log "🔍 Processing ${dir_name}/ directory"

            if ! format_terraform_directory "${dir}" "${check_mode}"; then
                has_errors=true
            fi
        else
            info "Directory not found: ${dir}"
        fi
    done

    if [[ "${has_errors}" == "true" ]]; then
        return 1
    fi

    success "All directories processed successfully"
    return 0
}

# Discover all Terraform files
discover_all_terraform_files() {
    log "🔍 Discovering all Terraform files in the repository"

    local directories=("${MODULES_DIR}" "${EXAMPLES_DIR}" "${TESTS_DIR}")
    local total_files=0

    for dir in "${directories[@]}"; do
        if [[ -d "${dir}" ]]; then
            local dir_name
            dir_name=$(basename "${dir}")
            log "📂 Scanning ${dir_name}/ directory"

            local files
            if files=$(discover_terraform_files "${dir}"); then
                list_discovered_files "${files}" "📄"
                local file_count
                file_count=$(echo "${files}" | wc -l)
                total_files=$((total_files + file_count))
            fi
        fi
    done

    success "Discovery complete! Found ${total_files} Terraform files total"
}

# Format Go files
format_go_files() {
    log "🐹 Formatting Go files..."

    # Change to tests directory where Go files are located
    if [[ -d "${TESTS_DIR}" ]]; then
        local original_dir
        original_dir=$(pwd)
        cd "${TESTS_DIR}" || error_exit "Failed to change to tests directory"

        if ! go fmt ./...; then
            cd "${original_dir}" || true
            error_exit "Go formatting failed"
        fi

        cd "${original_dir}" || error_exit "Failed to return to original directory"
        success "Go files formatted successfully"
    else
        info "Tests directory not found, skipping Go formatting"
    fi
}

# Format YAML files
format_yaml_files() {
    log "📄 Formatting YAML files..."

    local original_dir
    original_dir=$(pwd)
    cd "${PROJECT_ROOT}" || error_exit "Failed to change to project root"

    if ! yamlfmt .; then
        cd "${original_dir}" || true
        error_exit "YAML formatting failed"
    fi

    cd "${original_dir}" || error_exit "Failed to return to original directory"
    success "YAML files formatted successfully"
}

# Main function
main() {
    local format_all=true
    local format_terraform=false
    local format_go=false
    local format_yaml=false
    local tf_check_mode=false
    local tf_module=""
    local tf_discover=false
    local tf_all_dirs=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "${1}" in
            --help|-h)
                show_usage
                exit 0
                ;;
            --all)
                format_all=true
                shift
                ;;
            --terraform)
                format_all=false
                format_terraform=true
                shift
                ;;
            --go)
                format_all=false
                format_go=true
                shift
                ;;
            --yaml)
                format_all=false
                format_yaml=true
                shift
                ;;
            --tf-check)
                tf_check_mode=true
                shift
                ;;
            --tf-module)
                if [[ $# -lt 2 ]]; then
                    error_exit "--tf-module requires a module name"
                fi
                tf_module="${2}"
                shift 2
                ;;
            --tf-discover)
                tf_discover=true
                shift
                ;;
            --tf-all-dirs)
                tf_all_dirs=true
                shift
                ;;
            *)
                error_exit "Unknown argument: ${1}. Use --help for usage information."
                ;;
        esac
    done

    # Change to project root
    cd "${PROJECT_ROOT}" || error_exit "Failed to change to project root directory"

    # Handle Terraform operations
    if [[ "${format_all}" == "true" ]] || [[ "${format_terraform}" == "true" ]]; then
        if [[ "${tf_discover}" == "true" ]]; then
            discover_all_terraform_files
        elif [[ -n "${tf_module}" ]]; then
            format_terraform_module "${tf_module}" "${tf_check_mode}"
        elif [[ "${tf_all_dirs}" == "true" ]]; then
            format_terraform_all_directories "${tf_check_mode}"
        else
            # Default: format current directory and subdirectories
            format_terraform_directory "." "${tf_check_mode}"
        fi
    fi

    # Handle other file types
    if [[ "${format_all}" == "true" ]] || [[ "${format_go}" == "true" ]]; then
        format_go_files
    fi

    if [[ "${format_all}" == "true" ]] || [[ "${format_yaml}" == "true" ]]; then
        format_yaml_files
    fi

    success "Formatting operations completed successfully!"
}

# Run the main function
main "$@"
