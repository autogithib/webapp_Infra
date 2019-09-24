#prefix can be used to define the common name for all te resources
variable "cluster_name" {
  type = "string"
}

variable "cluster_location" {
  type = "string"
}

variable azure_subscription_id {
  type = "string"
}

variable azure_client_id {
  type = "string"
  default = var.client_id
}

variable azure_client_secret {
    type = "string"
    default = var.client_secret
}

variable azure_tenant_id {
  type = "string"
}

variable "instances" {
  description = "virtual machine names"
  type        = "list"
}

variable "admin_username" {
  type = "string"
}

variable "admin_password" {
  type = "string"
}
