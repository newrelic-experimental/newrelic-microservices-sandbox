output "vpc_id" {
  value = aws_vpc.nr_sandbox.id
}

output "cluster_id" {
  value = aws_eks_cluster.nr_sandbox.id
}


