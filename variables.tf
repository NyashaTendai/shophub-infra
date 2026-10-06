variable "project_id" {
  default = "project-45cfe394-2aee-40ec-a9a"
}

variable "region" {
  default = "us-central1"
}

variable "container_port" {
  default = 8080
}

variable "deploy_service" {
  type    = bool
  default = true
}

variable "image_tag" {
  default = "1.2"
}

variable "github_repo" {
  default = "NyashaTendai/shophub-ecommerce"
}
