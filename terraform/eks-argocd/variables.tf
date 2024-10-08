# variable "argocd_admin_password" {
#   type        = string
#   description = "The password to use for the `admin` Argo CD user."
# }

variable "enable_git_ssh" {
  description = "Use git ssh to access all git repos using format git@github.com:<org>"
  type        = bool
  default     = false
}
variable "ssh_key_path" {
  description = "SSH key path for git access"
  type        = string
  default     = "~/.ssh/id_rsa"
}
variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}
variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    # aws
    enable_cert_manager                 = true
    enable_aws_ebs_csi_resources        = true # generate gp2 and gp3 storage classes for ebs-csi
    enable_aws_cloudwatch_metrics       = true
    enable_external_secrets             = true
    enable_aws_load_balancer_controller = true
    enable_aws_for_fluentbit            = true
    enable_karpenter                    = false
    enable_aws_ingress_nginx            = true # inginx configured with AWS NLB
    # oss
    enable_metrics_server = true
    enable_kyverno        = true
    # Enable if want argo manage argo from gitops
    enable_argocd = false

    enable_aws_efs_csi_driver                    = false
    enable_aws_fsx_csi_driver                    = false
    enable_aws_privateca_issuer                  = false
    enable_cluster_autoscaler                    = false
    enable_external_dns                          = false
    enable_fargate_fluentbit                     = false
    enable_aws_node_termination_handler          = false
    enable_velero                                = false
    enable_aws_gateway_api_controller            = false
    enable_aws_secrets_store_csi_driver_provider = false
    enable_ack_apigatewayv2                      = false
    enable_ack_dynamodb                          = false
    enable_ack_s3                                = false
    enable_ack_rds                               = false
    enable_ack_prometheusservice                 = false
    enable_ack_emrcontainers                     = false
    enable_ack_sfn                               = false
    enable_ack_eventbridge                       = false

    enable_argo_rollouts                   = false
    enable_argo_events                     = false
    enable_argo_workflows                  = false
    enable_cluster_proportional_autoscaler = false
    enable_gatekeeper                      = false
    enable_gpu_operator                    = false
    enable_ingress_nginx                   = false
    enable_kube_prometheus_stack           = false
    enable_prometheus_adapter              = false
    enable_secrets_store_csi_driver        = false
    enable_vpa                             = false
  }
}

# Addons Git
variable "gitops_addons_org" {
  description = "Git repository org/user contains for addons"
  type        = string
  default     = "https://github.com/gitops-bridge-dev"
}
variable "gitops_addons_repo" {
  description = "Git repository contains for addons"
  type        = string
  default     = "kubecon-2023-na-argocon"
}
variable "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  type        = string
  default     = "main"
}
variable "gitops_addons_basepath" {
  description = "Git repository base path for addons"
  type        = string
  default     = "gitops/"
}
variable "gitops_addons_path" {
  description = "Git repository path for addons"
  type        = string
  default     = "bootstrap/control-plane/addons"
}
# Workloads Git
variable "gitops_workload_org" {
  description = "Git repository org/user contains for workload"
  type        = string
  default     = "https://github.com/gitops-bridge-dev"
}
variable "gitops_workload_repo" {
  description = "Git repository contains for workload"
  type        = string
  default     = "kubecon-2023-na-argocon"
}
variable "gitops_workload_revision" {
  description = "Git repository revision/branch/ref for workload"
  type        = string
  default     = "main"
}
variable "gitops_workload_basepath" {
  description = "Git repository base path for workload"
  type        = string
  default     = "gitops/"
}
variable "gitops_workload_path" {
  description = "Git repository path for workload"
  type        = string
  default     = "apps"
}

variable "enable_gitops_auto_bootstrap" {
  description = "Automatically deploy addons"
  type        = bool
  default     = true
}
