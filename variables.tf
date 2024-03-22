variable "namespace" {
  type        = string
  description = "Namespace for External DNS release"
}

variable "cluster_endpoint" {
  sensitive   = true
  type        = string
  description = "Endpoint of the cluster."
}

variable "cluster_ca" {
  sensitive   = true
  type        = string
  description = "CA certificate of the cluster."
}

variable "k8s_exec_args" {
  type        = list(string)
  description = "Args for Kubernetes provider exec plugin. Example command ['eks', 'get-token', '--cluster-name', '{clusterName}}']"
}

variable "k8s_exec_command" {
  type        = string
  description = "Command name for Kubernetes provider exec plugin. Example - 'aws"
}

variable "iam_role_arn" {
  type = string
  description = "IAM Role ARN to be attachted to service account."
}

variable "service_account_name" {}