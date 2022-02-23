resource "kubernetes_secret" "newrelic_applications" {

  metadata {
    name = "newrelic"
  }

  data = {
    (local.new_relic_license_key_k8s_secret_key_name) = var.new_relic_license_key
  }
}

resource "helm_release" "frontend" {

  depends_on = [helm_release.ingress_nginx]
  
  wait       = true
  timeout    = 600

  name       = "frontend"
  chart      = var.frontend_chart
  
  recreate_pods = true
  
  set {
    name = "new_relic.license_key.secret"
    value = kubernetes_secret.newrelic_applications.metadata[0].name
  }
  
  set {
    name = "new_relic.license_key.key"
    value = local.new_relic_license_key_k8s_secret_key_name
  }
  
}