terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.4.1"
    }
    aws = {
      source = "hashicorp/aws"
      version = "4.2.0"
    }
  }
}
