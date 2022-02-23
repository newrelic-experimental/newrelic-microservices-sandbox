resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx" {

  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  wait       = true
  timeout    = 600

  name       = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  
}

data "kubernetes_service" "ingress_nginx_controller" {
  depends_on = [helm_release.ingress_nginx]
  
  metadata {
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
    name = "ingress-nginx-controller"
  }
}