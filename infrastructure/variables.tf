variable "expected_account_id" {
  type = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.expected_account_id))
    error_message = "Enter your intended AWS account ID."
  }
}
variable "owner" {
  type = string
  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@veen\\.com$", var.owner))
    error_message = "The upstream module requires a valid @veen.com owner address."
  }
}
variable "app_owner" {
  type = string
  validation {
    condition     = can(regex("^[A-Za-z0-9._%+-]+@veen\\.com$", var.app_owner))
    error_message = "The upstream module requires a valid @veen.com app owner address."
  }
}
variable "approve_shared_route_change" {
  type    = bool
  default = false
}
