locals {
  env         = "staging"
  eks_name    = var.cluster_name
  eks_version = "1.31"
  
  tags = {
    project = var.cluster_name
    owner   = "aws"
  }
}