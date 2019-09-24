#prefix can be used to define the common name for all te resources
variable "cluster_name" {
  type = "string"
}

variable "cluster_location" {
  type = "string"
}

variable subscription_id {
  type = "string"
}

variable client_id {
  type = "string"
}

variable client_secret {
    type = "string"
}

variable tenant_id {
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
