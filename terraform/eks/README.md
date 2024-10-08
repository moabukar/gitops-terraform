# GitOps with Terraform

## Prerequisites

Before you begin, make sure you have the following command line tools installed:

- git
- terraform
- kubectl
- argocd
- akuity

Free trial account on [Akuity Platform](https://akuity.io/), and create an API Key with org access

```shell
export AKUITY_API_KEY_ID=xxxxxxxxxxxxx
export AKUITY_API_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxx
export AKUITY_SERVER_URL=https://akuity.cloud
# export TF_VAR_akp_org_name="your org name"
```

```shell
akuity login
```

Set the password you wan to access argocd

```shell
export TF_VAR_argocd_admin_password=xxxxxxxxxxx
```

## (Optional) Fork the GitOps git repositories

See the appendix section [Fork GitOps Repositories](#fork-gitops-repositories) for more info on the terraform variables to override.

## Deploy the Kubernetes Cluster

Initialize Terraform and deploy the EKS cluster:

```shell
terraform init
terraform apply -auto-approve
```

Retrieve `kubectl` config, then execute the output command:

```shell
terraform output -raw configure_kubectl
```

List the instances and clusters you created

```shell
akuity argocd instance list --organization-name eks-blueprints
akuity argocd cluster list --organization-name eks-blueprints --instance-name gitops-bridge
```

Terraform added GitOps Bridge Metadata to ArgoCD Instance.
The annotations contain metadata for the addons' Helm charts and ArgoCD ApplicationSets.

```shell
akuity argocd cluster get \
ex-eks-akuity-dev \
--organization-name eks-blueprints \
--instance-name gitops-bridge \
-o json | jq .data.annotations
```

The output looks like the following:

```json
{
  "addons_repo_basepath": "gitops/",
  "addons_repo_path": "bootstrap/control-plane/addons",
  "addons_repo_revision": "update-ek-examples-10-30",
  "addons_repo_url": "https://github.com/gitops-bridge-dev/kubecon-2023-na-argocon",
  "aws_account_id": "0123456789",
  "aws_cloudwatch_metrics_iam_role_arn": "arn:aws:iam::0123456789:role/aws-cloudwatch-metrics-20231031031132065600000004",
  "aws_cloudwatch_metrics_namespace": "amazon-cloudwatch",
  "aws_cloudwatch_metrics_service_account": "aws-cloudwatch-metrics",
  "aws_cluster_name": "ex-eks-akuity",
  "aws_for_fluentbit_iam_role_arn": "arn:aws:iam::0123456789:role/aws-for-fluent-bit-20231031031132065400000002",
  "aws_for_fluentbit_log_group_name": "/aws/eks/ex-eks-akuity/aws-fluentbit-logs-20231031031132064900000001",
  "aws_for_fluentbit_namespace": "kube-system",
  "aws_for_fluentbit_service_account": "aws-for-fluent-bit-sa",
  "aws_load_balancer_controller_iam_role_arn": "arn:aws:iam::0123456789:role/alb-controller-20231031031132066500000007",
  "aws_load_balancer_controller_namespace": "kube-system",
  "aws_load_balancer_controller_service_account": "aws-load-balancer-controller-sa",
  "aws_region": "us-west-2",
  "aws_vpc_id": "vpc-0208191bd2c629587",
  "cert_manager_iam_role_arn": "arn:aws:iam::0123456789:role/cert-manager-20231031031132065900000005",
  "cert_manager_namespace": "cert-manager",
  "cert_manager_service_account": "cert-manager",
  "external_secrets_iam_role_arn": "arn:aws:iam::0123456789:role/external-secrets-20231031031132065500000003",
  "external_secrets_namespace": "external-secrets",
  "external_secrets_service_account": "external-secrets-sa",
  "karpenter_iam_role_arn": "arn:aws:iam::0123456789:role/karpenter-20231031031132066700000008",
  "karpenter_namespace": "karpenter",
  "karpenter_node_instance_profile_name": "karpenter-ex-eks-akuity-20231031031132396100000009",
  "karpenter_service_account": "karpenter",
  "karpenter_sqs_queue_name": "karpenter-ex-eks-akuity",
  "workload_repo_basepath": "gitops/",
  "workload_repo_path": "apps",
  "workload_repo_revision": "update-ek-examples-10-30",
  "workload_repo_url": "https://github.com/gitops-bridge-dev/kubecon-2023-na-argocon"
}
```

The labels offer a straightforward way to enable or disable an addon in ArgoCD for the cluster.

```shell
akuity argocd cluster get \
ex-eks-akuity-dev \
--organization-name eks-blueprints \
--instance-name gitops-bridge \
-o json | jq .data.labels | grep -v false | jq .
```

The output looks like the following:

```json
{
  "aws_cluster_name": "ex-eks-akuity",
  "enable_aws_cloudwatch_metrics": "true",
  "enable_aws_ebs_csi_resources": "true",
  "enable_aws_for_fluentbit": "true",
  "enable_aws_ingress_nginx": "true",
  "enable_aws_load_balancer_controller": "true",
  "enable_cert_manager": "true",
  "enable_external_secrets": "true",
  "enable_karpenter": "true",
  "enable_kyverno": "true",
  "enable_metrics_server": "true",
  "environment": "dev",
  "kubernetes_version": "1.28"
}
```

### Login in ArgoCD CLI

```shell
export ARGOCD_SERVER=$(terraform output -raw akuity_server_addr)
export ARGOCD_OPTS="--grpc-web"
argocd login $ARGOCD_SERVER --username admin --password $TF_VAR_argocd_admin_password
```

### Monitor GitOps Progress for Addons

Wait until all the ArgoCD applications' `HEALTH STATUS` is `Healthy`. Use Crl+C to exit the `watch` command

```shell
watch argocd app list
```

### Verify the Addons

Verify that the addons are ready:

```shell
kubectl get deployment -A
```

### Monitor GitOps Progress for Workloads

Watch until the Workloads ArgoCD Application is `Healthy`

```shell
watch argocd app get guestbook
```

Wait until the ArgoCD Applications `HEALTH STATUS` is `Healthy`. Crl+C to exit the `watch` command

Output should look like the following:

```text
Name:               argocd/guestbook
Project:            default
Server:             ex-eks-akuity-dev
Namespace:          guestbook
URL:                https://aggowmg7gr5hbl23.cd.akuity.cloud/applications/guestbook
Repo:               https://github.com/gitops-bridge-dev/kubecon-2023-na-argocon
Target:             update-eks-10-31
Path:               gitops/apps/guestbook
SyncWindow:         Sync Allowed
Sync Policy:        Automated
Sync Status:        Synced to update-eks-10-31 (efd902c)
Health Status:      Healthy

GROUP              KIND        NAMESPACE  NAME          STATUS  HEALTH   HOOK  MESSAGE
                   Service     guestbook  guestbook-ui  Synced  Healthy        service/guestbook-ui unchanged
apps               Deployment  guestbook  guestbook-ui  Synced  Healthy        deployment.apps/guestbook-ui unchanged
networking.k8s.io  Ingress     guestbook  guestbook-ui  Synced  Healthy        ingress.networking.k8s.io/guestbook-ui created
```

### Verify the Application

Verify that the application configuration is present and the pod is running:

```shell
kubectl get -n guestbook deployments,service,ep,ingress
```

The expected output should look like the following:

```text
NAME                           READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/guestbook-ui   1/1     1            1           3m7s

NAME                   TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
service/guestbook-ui   ClusterIP   172.20.211.185   <none>        80/TCP    3m7s

NAME                     ENDPOINTS        AGE
endpoints/guestbook-ui   10.0.31.115:80   3m7s

NAME                   CLASS   HOSTS   ADDRESS                          PORTS   AGE
ingress/guestbook-ui   nginx   *       <>.elb.us-west-2.amazonaws.com   80      3m7s
```

### Access the Application using AWS Load Balancer

Verify the application endpoint health using `curl`:

```shell
kubectl exec -n guestbook deploy/guestbook-ui -- \
curl -I -s $(kubectl get -n ingress-nginx svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

The first line of the output should have `HTTP/1.1 200 OK`.

Retrieve the ingress URL for the application, and access in the browser:

```shell
echo "Application URL: http://$(kubectl get -n ingress-nginx svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
```

### Container Metrics

Check the application's CPU and memory metrics:

```shell
kubectl top pods -n guestbook
```

Check all pods CPU and memory metrics:

```shell
kubectl top pods -A
```

Output should look like the following:

```text
NAMESPACE           NAME                                                CPU(cores)   MEMORY(bytes)
akuity              akuity-agent-764cc87d89-2gmd6                       1m           10Mi
akuity              akuity-agent-764cc87d89-jjlvt                       1m           10Mi
akuity              argocd-application-controller-66664445b8-mmh8n      8m           154Mi
akuity              argocd-notifications-controller-7646fd4549-xzgjg    1m           19Mi
akuity              argocd-redis-6fd6f6556b-4l8px                       2m           4Mi
akuity              argocd-repo-server-6f8c6f6cf5-454t8                 1m           42Mi
akuity              argocd-repo-server-6f8c6f6cf5-6fj2d                 1m           35Mi
amazon-cloudwatch   aws-cloudwatch-metrics-7fh49                        11m          25Mi
amazon-cloudwatch   aws-cloudwatch-metrics-8879k                        10m          24Mi
cert-manager        cert-manager-55657857dd-xc9ww                       1m           15Mi
cert-manager        cert-manager-cainjector-7b5b5d4786-xtjbk            1m           25Mi
cert-manager        cert-manager-webhook-55fb5c9c88-w66h5               1m           8Mi
external-secrets    external-secrets-cb85c6976-hcg7m                    1m           19Mi
external-secrets    external-secrets-cert-controller-767c998588-ck8xj   1m           38Mi
external-secrets    external-secrets-webhook-9f9c4f65-wzptp             1m           18Mi
guestbook           guestbook-ui-7d6d6cbf96-qvbkg                       1m           9Mi
ingress-nginx       ingress-nginx-controller-7f9796776-gxpn7            1m           68Mi
ingress-nginx       ingress-nginx-controller-7f9796776-hlvmm            2m           68Mi
ingress-nginx       ingress-nginx-controller-7f9796776-v4x7t            2m           70Mi
karpenter           karpenter-799746c7c9-27ggv                          2m           25Mi
karpenter           karpenter-799746c7c9-p987j                          9m           46Mi
kube-system         aws-for-fluent-bit-bmfqf                            1m           19Mi
kube-system         aws-for-fluent-bit-gdxb6                            1m           21Mi
kube-system         aws-load-balancer-controller-55c676478-2dlz4        3m           27Mi
kube-system         aws-load-balancer-controller-55c676478-xc295        1m           20Mi
kube-system         aws-node-659vb                                      3m           56Mi
kube-system         aws-node-hjbkr                                      4m           59Mi
kube-system         coredns-59754897cf-8bct9                            2m           14Mi
kube-system         coredns-59754897cf-rthvl                            1m           14Mi
kube-system         ebs-csi-controller-86497db997-cxxdp                 4m           56Mi
kube-system         ebs-csi-controller-86497db997-qpxzk                 2m           51Mi
kube-system         ebs-csi-node-j2cpt                                  1m           21Mi
kube-system         ebs-csi-node-p6bzr                                  2m           21Mi
kube-system         kube-proxy-9ds98                                    1m           14Mi
kube-system         kube-proxy-hkw2f                                    1m           12Mi
kube-system         metrics-server-5b76987ff-ccdmr                      4m           16Mi
kyverno             kyverno-admission-controller-6f54d4786f-bdmgq       3m           82Mi
kyverno             kyverno-background-controller-696c6d575c-6r5z7      2m           30Mi
kyverno             kyverno-cleanup-controller-79dd5858df-69nkw         2m           19Mi
kyverno             kyverno-reports-controller-5fcd875795-mk2dr         1m           31Mi
```

## Destroy the Kubernetes Cluster

To tear down all the resources and the EKS cluster, run the following command:

```shell
./destroy.sh
```

### Manually deploy Bootstrap apps

Only applicable if you don't deploy the bootstrap by setting the following variable to false (default true)

```shell
export TF_VAR_enable_gitops_auto_bootstrap=false
```

#### Deploy the Addons

Bootstrap the addons using ArgoCD:

```shell
argocd appset create --upsert ../../gitops/bootstrap/control-plane/exclude/addons-akuity.yaml
```

#### Deploy the Workloads

Deploy a sample application located in [../../gitops/apps/guestbook](../../gitops/apps/guestbook) using ArgoCD:

```shell
argocd appset create --upsert ../../gitops/bootstrap/workloads/exclude/workloads-akuity.yaml
```
