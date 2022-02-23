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

variable "aws_region" {
    type = string
}
