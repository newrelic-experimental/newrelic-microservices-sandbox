provider "aws" {
  
  default_tags {
    tags = {
      automation  = "terraform"
      project     = var.cluster_name
      owner       = var.owner
    }
  }
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
  github_username = var.github_username
  github_pat = var.github_pat
  repository_name = var.repository_name
}

module "newrelic" {
  source = "./newrelic"
  new_relic_user_api_key = var.new_relic_user_api_key
  new_relic_account_id = var.new_relic_account_id
  new_relic_region = var.new_relic_region
  cluster_name = var.cluster_name
  owner = var.owner
}