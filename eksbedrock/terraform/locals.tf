locals {
  env         = "staging"
  eks_name    = "eksbedrock"
  eks_version = "1.31"
  
  tags = {
    project = "eksbedrock"
    owner   = "aws"
  }
}