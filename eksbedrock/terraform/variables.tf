
variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "default CIDR range of the VPC"
}
variable "aws_region" {
  default = "ap-southeast-1"
  description = "aws region"
}

variable "cluster_name" {
  default = "eksbedrock"
  description = "cluster name"
}


