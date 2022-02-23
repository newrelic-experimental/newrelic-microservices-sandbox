output "alb_hostname" {
  value = module.eks_cluster.alb_hostname
}

output "vpc_id" {
  value = module.eks_cluster.vpc_id
}

output "cluster_id" {
  value = module.eks_cluster.cluster_id
}

output "kubeconfig" {
  value = module.kubernetes_objects.kubeconfig
}
