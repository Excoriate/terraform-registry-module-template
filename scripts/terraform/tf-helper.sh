#!/usr/bin/env bash
#
##################################################################################
# Script Name: Terraform Modules Upgrader and Docs Generator
#
# Author: Alex Torres (github.com/Excoriate), alex_torres@outlook.com
#
# Usage: ./script.sh --modules_dir=modules_dir_path [--max_depth_flag=depth] [--action=action]
#
# Description: This bash script searches for Terraform modules within a specified directory
#              up to a certain depth and runs 'terraform init -upgrade' or generates docs
#              in each module's directory based on the specified action.
#
# Parameters:
#    --modules_dir:      The path to the directory containing Terraform modules [mandatory].
#    --max_depth_flag:   The maximum depth for directory traversal. Default is 3 [optional].
#    --action:           The action to perform: 'upgrade' (default) or 'docs' [optional].
#
# Examples:
#    Upgrade modules: ./script.sh --modules_dir=./modules --max_depth_flag=2 --action=upgrade
#    Generate docs: ./script.sh --modules_dir=./modules --max_depth_flag=2 --action=docs
#
# Note: The script assumes that Terraform and terraform-docs are installed and available on the system's PATH.
#
##################################################################################

set -euo pipefail

# Constants
readonly DEFAULT_ACTION="upgrade" # Supports "upgrade" or "docs"
readonly UPGRADE_EMOJI="🔼"
readonly DOCS_EMOJI="📄"
readonly SKIP_EMOJI="⏭️"
readonly ERROR_EMOJI="❌"
readonly SUCCESS_EMOJI="✅"

log() {
    local -r msg="${1}"
    local -r emoji="${2:-${SUCCESS_EMOJI}}"
    echo -e "${emoji} ${msg}" >&2
}

get_terraform_module_paths() {
    local -r modules_dir="${1}"
    local -r max_depth_flag="${2:-3}" # Default max depth is 3 if not provided

    find "${modules_dir}" -mindepth 1 -maxdepth "${max_depth_flag}" -type d -exec sh -c 'for dir; do ls "$dir"/*.tf >/dev/null 2>&1 && echo "$dir"; done' sh {} \;
}

perform_action() {
    local -r module_path="${1}"
    local -r action="${2}"

    case "${action}" in
        upgrade)
            log "Upgrading Terraform module at: ${module_path}" "${UPGRADE_EMOJI}"
            (cd "${module_path}" && terraform init -upgrade)
            ;;
        docs)
            log "Generating Terraform docs for module at: ${module_path}" "${DOCS_EMOJI}"
            (cd "${module_path}" && terraform-docs md . > README.md)
            ;;
        *)
            log "Skipping unknown action: ${action}" "${SKIP_EMOJI}"
            ;;
    esac
}

main() {
    local modules_dir=""
    local max_depth_flag=""
    local action="${DEFAULT_ACTION}"

    while (( $# )); do
        case "$1" in
            --modules_dir=*)
                modules_dir="${1#*=}"
                shift
                ;;
            --max_depth_flag=*)
                max_depth_flag="${1#*=}"
                shift
                ;;
            --action=*)
                action="${1#*=}"
                shift
                ;;
            *)
                log "Error: Invalid argument." "${ERROR_EMOJI}"
                exit 1
        esac
    done

    if [[ -z "${modules_dir}" ]]; then
        log "Error: Missing mandatory argument '--modules_dir'." "${ERROR_EMOJI}"
        exit 1
    fi

    local module_found=false
    local modules_path
    modules_path=$(get_terraform_module_paths "${modules_dir}" "${max_depth_flag}")
    echo "${modules_path}" | while read -r module_path; do
        module_found=true
        perform_action "${module_path}" "${action}"
    done

    if ! ${module_found}; then
        log "No Terraform modules found in the directory: ${modules_dir}" "${SKIP_EMOJI}"
        return 0
    fi

    log "Terraform modules processed successfully with action: ${action}" "${SUCCESS_EMOJI}"
}

main "$@"
