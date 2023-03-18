locals {
  service_account_name = "external-dns-sa"
}

resource "kubernetes_service_account" "external_dns_sa" {
  metadata {
    name      = local.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.iam_role.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
  secret {
    name = "cert-manager-sa-secret"
  }
  automount_service_account_token = true
}

module "iam_role" {
  source                     = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  role_name                  = "${var.stack}-external-dns"
  attach_external_dns_policy = true
  oidc_providers = {
    main = {
      provider_arn               = var.oidc_provider_arn
      namespace_service_accounts = ["${var.namespace}:${local.service_account_name}"]
    }
  }
}

resource "helm_release" "cert_manager" {
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "external-dns"
  name       = "external-dns"
  namespace  = var.namespace
  atomic     = true
  values = [
    yamlencode({
      fullnameOverride = "external-dns"
      serviceAccount = {
        create = false
        name   = kubernetes_service_account.external_dns_sa.metadata[0].name
      }
    })
  ]
}

