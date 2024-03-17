#!/usr/bin/env bash
#
# Script Name: Terraform and Terragrunt Cleaner
#
# Description: This script cleans either Terraform or Terragrunt directories within a specified directory
#              up to a certain depth.
#
# Usage:
#    Clean Terraform folders: ./script.sh --type=terraform --max_depth_flag=2
#    Clean Terragrunt folders: ./script.sh --type=terragrunt --max_depth_flag=2
#
# Parameters:
#    --type:             The type of directories to clean ('terraform' or 'terragrunt') [mandatory].
#    --max_depth_flag:   The maximum depth for directory traversal. Default is 3 [optional].
#
##################################################################################

set -euo pipefail

# Default values
readonly DEFAULT_MAX_DEPTH=3

log() {
    echo >&2 -e "$@"
}

clean_directories() {
    local dir_type="$1"
    local max_depth="$2"
    local dir_name="$3"
    local emoji="$4"
    local count=0

    log "${emoji} Examining ${dir_type} directories..."
    find . -maxdepth "${max_depth}" -type d -name "${dir_name}" -prune | while IFS= read -r dir; do
        log "${emoji} ${dir_type^^} FOUND => Cleaning ${dir}"
        rm -rf "${dir}"
        ((count=count+1))
    done

    if [[ $count -eq 0 ]]; then
        log "${emoji} No ${dir_type} directories to clean."
    else
        log "${emoji} Cleaned ${count} ${dir_type} directories."
    fi
}

parse_params() {
    local type
    local max_depth="${DEFAULT_MAX_DEPTH}"

    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --type=*)
                type="${1#*=}"
                shift
                ;;
            --max_depth_flag=*)
                max_depth="${1#*=}"
                shift
                ;;
            *)
                log "❌ Invalid parameter was provided: $1"
                exit 1
                ;;
        esac
    done

    if [[ -z "${type}" ]]; then
        log "❌ Error: --type is required."
        exit 1
    fi

    case "${type}" in
        terraform)
            clean_directories "terraform" "${max_depth}" ".terraform" "🔍"
            ;;
        terragrunt)
            clean_directories "terragrunt" "${max_depth}" ".terragrunt-cache" "🔎"
            ;;
        *)
            log "❌ Invalid type specified. Use 'terraform' or 'terragrunt'."
            exit 1
            ;;
    esac
}

parse_params "$@"
