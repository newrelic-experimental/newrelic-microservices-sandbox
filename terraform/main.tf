terraform {
  required_providers {
    newrelic = {
      source  = "newrelic/newrelic"
      version = "~> 2.44" 
    }
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

provider "aws" {
  
  default_tags {
    tags = {
      automation  = "terraform"
      project     = var.cluster_name
      owner       = var.owner
    }
  }
}

provider "newrelic" {
  account_id = var.new_relic_account_id
  api_key = var.new_relic_user_api_key
  region = var.new_relic_region                   # Valid regions are US and EU
}


module "eks_cluster" {
  source = "./eks-cluster"
  cluster_name = var.cluster_name
}

module "kubernetes_objects" {
  source = "./kubernetes-objects"
  cluster_name = module.eks_cluster.cluster_id
  new_relic_license_key = var.new_relic_license_key
  gateway_chart = abspath("${path.module}/../charts/gateway")
  superheroes_chart = abspath("${path.module}/../charts/superheroes")
  customers_chart = abspath("${path.module}/../charts/customers")
  mysql_chart = abspath("${path.module}/../charts/mysql")
  image_tag = var.image_tag
  registry_server = var.registry_server
  registry_username = var.registry_username
  registry_password = var.registry_password
  repository_basepath = var.repository_basepath
}

module "newrelic_resources" {
  depends_on = [module.kubernetes_objects]
  source = "./newrelic"
  new_relic_user_api_key = var.new_relic_user_api_key
  new_relic_account_id = var.new_relic_account_id
  new_relic_region = var.new_relic_region
  cluster_name = var.cluster_name
  owner = var.owner
}