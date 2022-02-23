output "alb_hostname" {
  value = aws_lb.nr_sandbox.dns_name
}

output "vpc_id" {
  value = aws_vpc.nr_sandbox.id
}

output "cluster_id" {
  value = aws_eks_cluster.nr_sandbox.id
}


