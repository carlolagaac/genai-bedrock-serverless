
resource "aws_ecr_repository" "bedrockragrepo" {
  name                 = "bedrockragrepo"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_authorization_token" "token" {}

# configure docker provider
provider "docker" {
  registry_auth {
      address = data.aws_ecr_authorization_token.token.proxy_endpoint
      username = data.aws_ecr_authorization_token.token.user_name
      password  = data.aws_ecr_authorization_token.token.password
    }
}


# build docker image for Graviton (ARM64)
resource "docker_image" "bedrockrag-image-arm64" {
  name = "${aws_ecr_repository.bedrockragrepo.repository_url}:arm64-latest"
  platform = "linux/arm64"
  build {
    context = "../bedrockrag"
    tag = ["${aws_ecr_repository.bedrockragrepo.repository_url}:arm64-latest"]
    platform = "linux/arm64"
    no_cache = true
  }
}

# build docker image for AMD64
resource "docker_image" "bedrockrag-image-amd64" {
  name = "${aws_ecr_repository.bedrockragrepo.repository_url}:amd64-latest"
  platform = "linux/amd64"
  build {
    context = "../bedrockrag"
    tag = ["${aws_ecr_repository.bedrockragrepo.repository_url}:amd64-latest"]
    platform = "linux/amd64"
    no_cache = true
  }
}

# push images to ecr repo
resource "docker_registry_image" "push-bedrockrag-image-arm64" {
  name = docker_image.bedrockrag-image-arm64.name
}

resource "docker_registry_image" "push-bedrockrag-image-amd64" {
  name = docker_image.bedrockrag-image-amd64.name
}


