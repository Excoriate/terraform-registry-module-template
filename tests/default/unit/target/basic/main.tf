module "target" {
  source         = "../../../../../modules/default"
  aws_region     = var.aws_region
  is_enabled     = var.is_enabled
}

provider "aws" {
  region = var.aws_region
}

# ----------------------------------
# Emulate input variables required by
# the target module
# ----------------------------------
variable "is_enabled" {
  type = bool
}

variable "aws_region" {
  type = string
}

# ----------------------------------
# Emulate output variables provided by
# the target module
# ----------------------------------
output "is_enabled" {
  value = var.is_enabled
}
