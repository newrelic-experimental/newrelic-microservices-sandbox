output "alb-hostname" {
  value = aws_lb.k8s-acc.dns_name
}

output "kubeconfig" {
  value = abspath("${path.root}/${local_file.kubeconfig.filename}")
}
