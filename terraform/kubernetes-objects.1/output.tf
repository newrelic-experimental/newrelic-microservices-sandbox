output "kubeconfig" {
  value = abspath("${path.module}/${local_file.kubeconfig.filename}")
}

output "loadbalancer_hostname" {
  value = data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname
}
