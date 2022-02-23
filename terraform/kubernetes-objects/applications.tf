resource "helm_release" "frontend" {

  depends_on = [helm_release.ingress_nginx]
  
  wait       = true
  timeout    = 600

  name       = "frontend"
  chart      = var.frontend_chart
  
}