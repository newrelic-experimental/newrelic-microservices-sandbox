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

variable "github_username" {
  type = string
}

variable "github_pat" {
  type = string
}

variable "repository_name" {
  type = string
}