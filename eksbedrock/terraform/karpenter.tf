module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.15.1"

  cluster_name = module.eks.cluster_name

  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter/"
  chart      = "karpenter"
  version    = "v1.4.0"

  set {
    name  = "settings.aws.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }

  depends_on = [
    module.eks.eks_managed_node_groups
  ]
}

# Create a default Karpenter Provisioner
resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
apiVersion: karpenter.sh/v1
kind: Provisioner
metadata:
  name: default
spec:
  requirements:
    - key: kubernetes.io/arch
      operator: In
      values: ["amd64", "arm64"]
    - key: karpenter.sh/capacity-type
      operator: In
      values: ["spot", "on-demand"]
  consolidation:
    enabled: true
  limits:
    resources:
      cpu: 1
      memory: 1Gi
  providerRef:
    name: default
  ttlSecondsUntilExpired: 2592000
  YAML

  depends_on = [
    helm_release.karpenter
  ]
}

# Create a default Karpenter NodePool
resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
apiVersion: karpenter.k8s.aws/v1
kind: AWSNodeTemplate
metadata:
  name: default
spec:
  subnetSelector:
    karpenter.sh/discovery: "${module.eks.cluster_name}"
  securityGroupSelector:
    karpenter.sh/discovery: "${module.eks.cluster_name}"
  instanceProfile: "${module.karpenter.instance_profile_name}"
  tags:
    karpenter.sh/discovery: "${module.eks.cluster_name}"
  capacityType: SPOT
  blockDeviceMappings:
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 20Gi
        volumeType: gp3
  instanceTypes:
    - t3.large
    - t3.xlarge
    - t3.2xlarge
    - t4g.large
    - t4g.xlarge
    - t4g.2xlarge
  YAML

  depends_on = [
    kubectl_manifest.karpenter_provisioner
  ]
}