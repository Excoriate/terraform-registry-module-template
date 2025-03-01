variable "is_enabled" {
  type        = bool
  description = "Whether this module will be created or not."
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources."
  default     = {}
}
