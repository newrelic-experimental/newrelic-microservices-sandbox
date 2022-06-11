variable "cluster_name" {
  type = string
  default = "newrelic-microservices-sandbox"
}

variable "owner" {
  type = string
}

variable "new_relic_license_key" {
    type = string
}

variable "new_relic_user_api_key" {
    type = string
}

variable "new_relic_account_id" {
    type = string
}

variable "new_relic_region" {
    type = string
    default = "US"
}

variable "image_tag" {
  type = string
}

variable "registry_server" {
  type = string
  default = "ghcr.io"
}

variable "registry_username" {
  type = string
  default = null
}

variable "registry_password" {
  type = string
  default = null
}

variable "repository_basepath" {
  type = string
}