locals {
  new_relic_license_key_k8s_secret = "license_key"
}

data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.nr-sandbox.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.nr-sandbox.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.default.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.nr-sandbox.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.nr-sandbox.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.default.token
  }
}

resource "local_file" "kubeconfig" {
  sensitive_content = templatefile("${path.module}/kubeconfig.tpl", {
    cluster_name = var.cluster_name,
    clusterca    = data.aws_eks_cluster.nr-sandbox.certificate_authority[0].data,
    endpoint     = data.aws_eks_cluster.nr-sandbox.endpoint,
    })
  filename          = "./${var.cluster_name}.kubeconfig"
}

# BEGIN New Relic bundle

resource "kubernetes_namespace" "newrelic" {
  metadata {
    name = "newrelic"
  }
}

resource "kubernetes_secret" "newrelic" {

  metadata {
    name = "newrelic"
    namespace = kubernetes_namespace.newrelic.metadata[0].name
  }

  data = {
    (local.new_relic_license_key_k8s_secret) = var.new_relic_license_key
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
    value = kubernetes_secret.newrelic.metadata[0].name
  }
  
  set {
    name = "global.customSecretLicenseKey"
    value = local.new_relic_license_key_k8s_secret
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
	  name = "global.lowDataMode"
	  value = true
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

#END New Relic bundle
