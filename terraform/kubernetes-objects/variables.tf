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