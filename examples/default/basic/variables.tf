###################################
# Input Variables 🛠️
# ----------------------------------------------------
#
# These variables allow users to customize the module according to their needs.
# Each variable is documented with its description, type, and default value if applicable.
#
###################################

variable "is_enabled" {
  type        = bool
  description = <<-DESC
  Whether this module will be created or not. Useful for stack-composite
  modules that conditionally include resources provided by this module.
  DESC
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources."
  default     = {}
}
