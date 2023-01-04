terraform {
  required_version = ">= 1.3.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.48.0, < 5.0.0"
    }
    // FIXME: Remove, refactor or change. (Template)
    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}
