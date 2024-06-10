resource "kubernetes_service_account" "external_dns_sa" {
  metadata {
    name        = var.service_account_name
    namespace   = var.namespace
    annotations = var.service_account_annotations
  }
  secret {
    name = "cert-manager-sa-secret"
  }
  automount_service_account_token = true
}

resource "helm_release" "cert_manager" {
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  name       = "external-dns"
  version    = "1.14.5"
  namespace  = var.namespace
  atomic     = true
  values = [
    yamlencode({
      fullnameOverride = "external-dns"
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.external_dns_sa.metadata[0].name
      }
      policy = "sync"
    })
  ]
}

