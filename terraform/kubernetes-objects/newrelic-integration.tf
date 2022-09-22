resource "kubernetes_namespace" "newrelic" {
  metadata {
    name = "newrelic"
  }
}

resource "kubernetes_secret" "newrelic_integration" {

  metadata {
    name = "newrelic"
    namespace = kubernetes_namespace.newrelic.metadata[0].name
  }

  data = {
    (local.new_relic_license_key_k8s_secret_key_name) = var.new_relic_license_key
  }
}

resource "helm_release" "newrelic" {
  namespace  = kubernetes_namespace.newrelic.metadata[0].name
  wait       = true
  timeout    = 600

  name       = "newrelic-bundle"

  repository = "https://helm-charts.newrelic.com"
  chart      = "nri-bundle"
  
  set {
    name = "global.customSecretName"
    value = kubernetes_secret.newrelic_integration.metadata[0].name
  }
  
  set {
    name = "global.customSecretLicenseKey"
    value = local.new_relic_license_key_k8s_secret_key_name
  }
  
  set {
    name = "global.cluster"
    value = var.cluster_name
  }
  
  set {
    name = "global.lowDataMode"
    value = true
  }
  
  set {
    name = "newrelic-infrastructure.privileged"
    value =true
  }
  
  set {
	  name = "ksm.enabled"
	  value = true
  }
  
  set {
	  name = "kubeEvents.enabled"
	  value = true
  }
  
  set {
	  name = "logging.enabled"
	  value = true
  }
  
  set {
	  name = "prometheus.enabled"
	  value = true
  } 
}
