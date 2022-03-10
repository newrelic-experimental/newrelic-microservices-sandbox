provider "aws" {

  region = var.aws_region
  
  default_tags {
    tags = {
      Created_By  = "Terraform"
      Project     = var.cluster_name
      Owner       = var.owner
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
  frontend_chart = abspath("${path.module}/../charts/frontend")
  superheroes_chart = abspath("${path.module}/../charts/superheroes")
}