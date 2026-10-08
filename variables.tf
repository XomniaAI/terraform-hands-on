variable "your_name" {
  description = "Your name. It goes on your web page and into the storage account name."
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2,12}$", var.your_name))
    error_message = "Use 2 to 12 lowercase letters, no spaces or digits. Example: \"anna\"."
  }
}

variable "colour" {
  description = "The background colour of your page: a CSS colour name or hex code."
  type        = string
  default     = "teal"
}
