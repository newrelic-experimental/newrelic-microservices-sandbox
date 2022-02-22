variable "cluster_name" {
  type = string
  default = "newrelic-microservices-sandbox"
}

variable "owner" {
  type = string
}

variable "kubernetes_version" {
  type    = string
  default = "1.21"
}
