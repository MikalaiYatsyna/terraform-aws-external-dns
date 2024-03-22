resource "kubernetes_service_account" "external_dns_sa" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn"               = var.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
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
  version    = "1.14.3"
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

