resource "kubernetes_secret" "newrelic_applications" {

  metadata {
    name = "newrelic"
  }

  data = {
    (local.new_relic_license_key_k8s_secret_key_name) = var.new_relic_license_key
  }
}

resource "helm_release" "gateway" {

  depends_on = [helm_release.ingress_nginx]
  
  wait       = true
  timeout    = 600

  name       = "gateway"
  chart      = var.gateway_chart
  
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

resource "helm_release" "superheroes" {

  depends_on = [helm_release.ingress_nginx]
  
  wait       = true
  timeout    = 600

  name       = "superheroes"
  chart      = var.superheroes_chart
  
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
  
resource "helm_release" "customers" {

  depends_on = [helm_release.ingress_nginx, helm_release.mysql]
  
  wait       = true
  timeout    = 600

  name       = "customers"
  chart      = var.customers_chart
  
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

resource "helm_release" "mysql" {

  depends_on = [helm_release.ingress_nginx]
  
  wait       = true
  timeout    = 600

  name       = "mysql"
  chart      = var.mysql_chart
  
  recreate_pods = true
  
}

resource "kubernetes_config_map" "locustfile" {
  metadata {
    name = "locustfile"
  }

  data = {
    "locustfile.py" = "${file("${path.module}/../../apps/loadgen/locustfile.py")}"
  }

}

resource "helm_release" "loadgen" {

  depends_on = [data.kubernetes_service.ingress_nginx_controller, kubernetes_config_map.locustfile, helm_release.gateway, helm_release.customers]
  
  wait       = true
  timeout    = 600

  name       = "loadgen"
  repository = "https://charts.deliveryhero.io/"
  chart      = "locust"
  
  recreate_pods = true
  
  set {
    name = "loadtest.headless"
    value = kubernetes_config_map.locustfile.metadata[0].name
  }
  
  set {
    name = "loadtest.locust_locustfile_configmap"
    value = kubernetes_config_map.locustfile.metadata[0].name
  }
  
  set {
    name = "loadtest.locust_locustfile"
    value = "locustfile.py"
  }
  
  set {
    name = "loadtest.locust_host"
    value = "http://${data.kubernetes_service.ingress_nginx_controller.status.0.load_balancer.0.ingress.0.hostname}"
  }
  
  # set {
  #   name = "master.args"
  #   value = "--users 10"
  # }
  
  values = [ yamlencode({ "master": { "args": ["--users", "300"] }}) ]
  
}
  