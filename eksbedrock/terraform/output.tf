output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.bedrockragrepo.repository_url
}

output "ecr_repository_arn" {
  description = "The ARN of the ECR repository"
  value       = aws_ecr_repository.bedrockragrepo.arn
}

output "ecr_repository_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.bedrockragrepo.name
}

output "aws_load_balancer_controller_role_arn" {
  description = "The IAM Role ARN for the AWS Load Balancer Controller"
  value       = module.aws_load_balancer_controller_irsa_role.iam_role_arn
}

output "aws_load_balancer_controller_role_name" {
  description = "The IAM Role name for the AWS Load Balancer Controller"
  value       = module.aws_load_balancer_controller_irsa_role.iam_role_name
}

output "cluster_endpoint" {
  description = "The endpoint for the EKS cluster"
  value       = module.eks.cluster_endpoint
}

output "karpenter_iam_role_arn" {
  description = "The IAM Role ARN for Karpenter"
  value       = aws_iam_role.karpenter_controller.arn
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = module.eks.cluster_name
}


