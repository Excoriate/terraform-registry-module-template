#!/usr/bin/env bash
# Formatting script for Terraform, Go, and YAML files

# Fail on any error and treat unset variables as an error
set -euo pipefail

# Logging function
log() {
    local message="$1"
    echo "🎨 ${message}"
}

# Error handling function
error_exit() {
    local message="$1"
    echo "❌ Error: ${message}" >&2
    exit 1
}

# Main formatting function
main() {
    local format_all=true
    local format_terraform=false
    local format_go=false
    local format_yaml=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
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
            *)
                error_exit "Unknown argument: $1"
                ;;
        esac
    done

    # Default to all if no specific format selected
    if [ "$format_all" = true ] || [ "$format_terraform" = true ]; then
        log "🌿 Searching for Terraform files to format..."

        # Find Terraform files and log directories
        terraform_files=$(find . -type f \( -name "*.tf" -o -name "*.tfvars" \))

        if [ -z "$terraform_files" ]; then
            log "ℹ️ No Terraform files found to format."
        else
            # Group files by directory and log
            echo "$terraform_files" | while read -r file; do
                dir=$(dirname "$file")
                log "🌿 Found Terraform files in: $dir"
            done | sort -u

            log "🌿 Formatting Terraform files..."
            if ! find . -type f \( -name "*.tf" -o -name "*.tfvars" \) -print0 | xargs -0 terraform fmt -recursive; then
                error_exit "Terraform formatting failed"
            fi
        fi
    fi

    if [ "$format_all" = true ] || [ "$format_go" = true ]; then
        log "🐹 Formatting Go files..."
        if ! go fmt ./...; then
            error_exit "Go formatting failed"
        fi
    fi

    if [ "$format_all" = true ] || [ "$format_yaml" = true ]; then
        log "📄 Formatting YAML files..."
        if ! yamlfmt .; then
            error_exit "YAML formatting failed"
        fi
    fi

    log "✅ Formatting complete!"
}

# Run the main function
main "$@"
