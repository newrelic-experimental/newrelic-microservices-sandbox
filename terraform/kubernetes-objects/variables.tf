variable "cluster_name" {
    type = string
}

variable "new_relic_license_key" {
    type = string
}

variable "gateway_chart" {
  type = string
}

variable "superheroes_chart" {
  type = string
}

variable "customers_chart" {
  type = string
}

variable "mysql_chart" {
  type = string
}

variable "image_tag" {
  type = string
  default = null
}

variable "registry_server" {
  type = string
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