module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name    = "eksbedrock"

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  enable_irsa = true

  # Add required policies for Karpenter
  iam_role_additional_policies = {
    AmazonBedrockFullAccess = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
  }

  # Add a small managed node group to run Karpenter
  eks_managed_node_groups = {
    karpenter = {
      instance_types = ["t3.small"]
      min_size     = 1
      max_size     = 2
      desired_size = 1

      labels = {
        role = "karpenter"
      }
    }
  }
}