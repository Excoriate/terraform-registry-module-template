###################################
# Target Test Configuration for Default Module 🎯
# ----------------------------------------------------
#
# This configuration demonstrates a basic use case
# for the default module, showcasing its core functionality
# and configuration options.
#
###################################

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Simulated AWS provider configuration
provider "aws" {
  region = "us-east-1"  # Adjust as needed
}

# Module instantiation with basic configuration
module "this" {
  source = "../../../../../modules/default"

  # Enable the module
  is_enabled = true

  # Add descriptive tags for tracking and management
  tags = {
    environment = "testing"
    module      = "default"
    purpose     = "terratest-validation"
    managed-by  = "terraform"
  }
}

# Optional: Output module results for verification
output "module_is_enabled" {
  description = "Confirm module is enabled"
  value       = module.this.is_enabled
}

output "module_tags" {
  description = "Verify tags applied to the module"
  value       = module.this.tags_set
}
