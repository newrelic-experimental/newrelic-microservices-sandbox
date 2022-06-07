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

variable "image_repository_base" {
  type = string
}

variable "image_tag" {
  type = string
  default = null
}

variable "customers_tag" {
  type = string
  default = null
}

variable "gateway_tag" {
  type = string
  default = null
}

variable "mysql_tag" {
  type = string
  default = null
}

variable "superheroes_tag" {
  type = string
  default = null
}
